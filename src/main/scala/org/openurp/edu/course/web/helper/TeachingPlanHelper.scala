/*
 * Copyright (C) 2014, The OpenURP Software.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package org.openurp.edu.course.web.helper

import org.beangle.commons.collection.Collections
import org.beangle.data.dao.{EntityDao, OqlBuilder}
import org.openurp.base.model.AuditStatus
import org.openurp.edu.clazz.model.Clazz
import org.openurp.edu.course.model.{CourseTask, Syllabus, TeachingPlan}
import org.openurp.edu.schedule.service.{LessonSchedule, ScheduleDigestor}

import java.time.{LocalDate, LocalTime}
import java.util.Locale

class TeachingPlanHelper(entityDao: EntityDao) {
  def findSyllabus(clazz: Clazz): Option[Syllabus] = {
    val query = OqlBuilder.from(classOf[Syllabus], "s")
    query.where("s.course=:course", clazz.course)
    query.where("s.beginOn<=:beginOn and (s.endOn is null or s.endOn >:endOn)", clazz.semester.beginOn, clazz.semester.beginOn)
    query.orderBy("s.beginOn desc")
    val syllabuses = entityDao.search(query)
    if (syllabuses.size == 1) { //大纲只有一份
      syllabuses.headOption
    } else {
      //从修订任务中查找符合该课程的修订任务
      val q = OqlBuilder.from(classOf[CourseTask], "t")
      q.where("t.course=:course", clazz.course)
      q.where("t.semester=:semester", clazz.semester)
      val clazzTeachers = clazz.teachers.toSet

      val tasks = entityDao.search(q).filter(x => clazzTeachers.subsetOf(x.teachers))
      if (tasks.isEmpty) {
        chooseZhFirst(syllabuses)
      } else {
        val writerCodes = tasks.flatMap(_.director.map(_.code)).toSet
        val taskSyllabuses = syllabuses.filter(x => writerCodes.contains(x.writer.code))
        chooseZhFirst(taskSyllabuses)
      }
    }
  }

  /** 优先选择中文大纲
   *
   * @param syllabuses
   * @return
   */
  private def chooseZhFirst(syllabuses: Iterable[Syllabus]): Option[Syllabus] = {
    if (syllabuses.size < 2) {
      syllabuses.headOption
    } else {
      val zh = Locale.SIMPLIFIED_CHINESE
      val nonDraft = syllabuses.filter(_.status != AuditStatus.Draft)
      if (nonDraft.nonEmpty) {
        nonDraft.find(_.docLocale == zh).orElse(nonDraft.headOption)
      } else {
        syllabuses.find(_.docLocale == zh).orElse(syllabuses.headOption)
      }
    }
  }

  def collectDatas(plan: TeachingPlan): collection.Map[String, Any] = {
    val datas = Collections.newMap[String, Any]

    val clazz = plan.clazz
    datas.put("plan", plan)
    datas.put("clazz", clazz)
    datas.put("schedule_time", ScheduleDigestor.digest(clazz, ":day :units :weeks"))
    datas.put("schedule_space", ScheduleDigestor.digest(clazz, ":room"))
    val dates = Collections.newBuffer[LocalDate]
    val semester = clazz.semester
    val beginAt = semester.beginOn.atTime(LocalTime.MIN)
    val endAt = semester.endOn.atTime(LocalTime.MAX)

    datas.put("syllabus", findSyllabus(clazz))
    val schedules = LessonSchedule.convert(clazz)
    datas.put("schedules", schedules)

    datas
  }
}
