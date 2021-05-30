/*
 * OpenURP, Agile University Resource Planning Solution.
 *
 * Copyright © 2014, The OpenURP Software.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful.
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.openurp.edu.course.web.action

import java.time.Instant

import org.beangle.data.dao.OqlBuilder
import org.beangle.security.Securities
import org.beangle.webmvc.api.annotation.{mapping, param}
import org.beangle.webmvc.api.view.View
import org.beangle.webmvc.entity.action.EntityAction
import org.openurp.base.model.User
import org.openurp.edu.base.model.Course
import org.openurp.edu.course.model.CourseProfile

class ReviseAction extends EntityAction[CourseProfile] {

  @mapping("{id}")
  def index(@param("id") id: String): View = {
    val course = entityDao.get(classOf[Course], id.toLong)
    put("profile", getProfile(course))
    put("course", course)
    forward()
  }

  private def getProfile(course: Course): Option[CourseProfile] = {
    val query = OqlBuilder.from(classOf[CourseProfile], "cp")
    query.where("cp.course = :course", course)
    entityDao.search(query).headOption
  }

  @mapping(value = "{id}/edit")
  def edit(@param("id") id: String): View = {
    val course = entityDao.get(classOf[Course], id.toLong)
    val profile = getProfile(course) match {
      case Some(p) => p
      case None => val cp = new CourseProfile
        cp.course = course
        cp
    }
    put("profile", profile)
    put("course", course)
    forward()
  }

  @mapping(value = "{id}", method = "put")
  def update(@param("id") id: String): View = {
    val entity = populate(getModel(id), entityName, simpleEntityName)
    persist(entity)
  }

  @mapping(method = "post")
  def save(): View = {
    persist(populateEntity())
  }

  override protected def simpleEntityName: String = {
    "profile"
  }

  def persist(profile: CourseProfile): View = {
    profile.updatedAt = Instant.now
    profile.updatedBy = entityDao.findBy(classOf[User], "code", List(Securities.user)).headOption
    entityDao.saveOrUpdate(profile)
    redirect("index", "id=" + profile.course.id, "info.save.success")
  }
}
