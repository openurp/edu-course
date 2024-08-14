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

import org.beangle.ems.app.Ems
import org.beangle.security.Securities
import org.beangle.web.action.context.ActionContext

@deprecated("using EmsApi.url")
object EmsUrl {

  def url(uri: String): String = {
    val base = Ems.base + ActionContext.current.request.getContextPath + uri
    val sidParam = "URP_SID=" + Securities.session.map(_.id).getOrElse("")
    if base.contains("?") then s"${base}&$sidParam" else s"${base}?$sidParam"
  }
}
