import org.openurp.parent.Dependencies._
import org.openurp.parent.Settings._

ThisBuild / organization := "org.openurp.edu.course"
ThisBuild / version := "0.0.2-SNAPSHOT"

ThisBuild / scmInfo := Some(
  ScmInfo(
    url("https://github.com/openurp/edu-course"),
    "scm:git@github.com:openurp/edu-course.git"
  )
)

ThisBuild / developers := List(
  Developer(
    id    = "chaostone",
    name  = "Tihua Duan",
    email = "duantihua@gmail.com",
    url   = url("http://github.com/duantihua")
  )
)

ThisBuild / description := "OpenURP Edu Course"
ThisBuild / homepage := Some(url("http://openurp.github.io/edu-course/index.html"))

val apiVer = "0.25.0"
val starterVer = "0.0.2-SNAPSHOT9"
val baseVer = "0.1.27"
val openurp_edu_api = "org.openurp.edu" % "openurp-edu-api" % apiVer
val openurp_stater_web = "org.openurp.starter" % "openurp-starter-web" % starterVer
val openurp_base_tag = "org.openurp.base" % "openurp-base-tag" % baseVer

lazy val root = (project in file("."))
  .settings()
  .aggregate(web,webapp)

lazy val web = (project in file("web"))
  .settings(
    name := "openurp-edu-course-web",
    common,
    libraryDependencies ++= Seq(openurp_edu_api,beangle_ems_app,openurp_stater_web,openurp_base_tag)
  )

lazy val webapp = (project in file("webapp"))
  .enablePlugins(WarPlugin,TomcatPlugin)
  .settings(
    name := "openurp-edu-course-webapp",
    common
  ).dependsOn(web)

publish / skip := true
