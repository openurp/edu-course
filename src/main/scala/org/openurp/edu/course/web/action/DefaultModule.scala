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

package org.openurp.edu.course.web.action

import org.beangle.commons.cdi.BindModule
import org.openurp.edu.clazz.domain.DefaultClazzProvider
import org.openurp.edu.course.service.impl.{CourseTaskServiceImpl, SyllabusServiceImpl}
import org.openurp.edu.course.web.action.profile.DepartAction

class DefaultModule extends BindModule {

  override protected def binding(): Unit = {
    bind(classOf[admin.TaskAction])
    bind(classOf[admin.DirectorAction], classOf[admin.JournalAction])
    bind(classOf[admin.NewCourseApplyAction], classOf[admin.NewCourseAuditAction])
    bind(classOf[admin.AwardAction], classOf[admin.SettingAction])

    bind(classOf[syllabus.ReviseAction], classOf[syllabus.OfficeAction])
    bind(classOf[syllabus.AuditAction], classOf[syllabus.DepartAction])

    bind(classOf[plan.ReviseAction], classOf[plan.OfficeAction])
    bind(classOf[plan.AuditAction], classOf[plan.DepartAction])

    bind(classOf[profile.ReviseAction], classOf[profile.InfoAction])
    bind(classOf[DepartAction])

    bind(classOf[program.ReviseAction], classOf[program.DepartAction])
    bind(classOf[program.OfficeAction])

    bind(classOf[info.SyllabusAction])

    bind(classOf[SyllabusServiceImpl])
    bind(classOf[CourseTaskServiceImpl])

    bind(classOf[experiment.DepartAction], classOf[experiment.NoneExpAction])

    bind(classOf[assess.CourseAction])

    bind(classOf[DefaultClazzProvider])
  }
}
