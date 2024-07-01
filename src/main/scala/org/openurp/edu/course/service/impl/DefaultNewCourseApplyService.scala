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

package org.openurp.edu.course.service.impl

import org.beangle.data.dao.{EntityDao, OqlBuilder}
import org.openurp.base.edu.model.Course
import org.openurp.edu.course.flow.NewCourseApply
import org.openurp.edu.course.service.NewCourseApplyService

/** 缺省新开课申请服务
 * FIXME 支持脚本化检查业务逻辑
 */
class DefaultNewCourseApplyService extends NewCourseApplyService {

  var entityDao: EntityDao = _

  /** 本学院没有开过，但是其他学院如果开设了同名课程，则不允许申请
   *
   * @param apply
   * @return
   */
  override def check(apply: NewCourseApply): Seq[String] = {
    val query1 = OqlBuilder.from(classOf[Course], "c")
    query1.where("c.project=:project", apply.project)
    query1.where("c.department = :depart", apply.department)
    query1.where("c.name=:name", apply.name)
    val ownCourses = entityDao.search(query1)
    if (ownCourses.nonEmpty) {
      Seq.empty
    } else {
      val query = OqlBuilder.from(classOf[Course], "c")
      query.where("c.project=:project", apply.project)
      query.where("c.department != :depart", apply.department)
      query.where("c.name=:name", apply.name)
      val otherCourses = entityDao.search(query)
      if (otherCourses.nonEmpty) {
        val h = otherCourses.head
        Seq(s"${h.department.name}已经开设了类似课程${h.code} ${h.name}")
      } else {
        Seq.empty
      }
    }
  }
}
