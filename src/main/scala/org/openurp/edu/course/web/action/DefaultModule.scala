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

import org.beangle.cdi.bind.BindModule
import org.openurp.edu.clazz.domain.DefaultClazzProvider
import org.openurp.edu.course.service.impl.{CourseTaskServiceImpl, SyllabusServiceImpl}

class DefaultModule extends BindModule {

  override protected def binding(): Unit = {
    bind(classOf[profile.ReviseAction], classOf[profile.InfoAction])
    bind(classOf[admin.DepartAction], classOf[admin.TaskAction])
    bind(classOf[admin.DirectorAction])

    bind(classOf[plan.ReviseAction], classOf[plan.DepartAction])

    bind(classOf[syllabus.ReviseAction], classOf[syllabus.OfficeAction])
    bind(classOf[syllabus.AuditAction], classOf[syllabus.DepartAction])

    bind(classOf[SyllabusServiceImpl])
    bind(classOf[CourseTaskServiceImpl])

    bind(classOf[DefaultClazzProvider])
  }
}
