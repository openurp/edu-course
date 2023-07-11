import org.openurp.parent.Settings._
import org.openurp.parent.Dependencies._

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

ThisBuild / description := "The OpenURP Edu Course"
ThisBuild / homepage := Some(url("http://openurp.github.io/edu-course/index.html"))
ThisBuild / resolvers += Resolver.mavenLocal

val apiVer = "0.33.3-SNAPSHOT"
val starterVer = "0.3.4"
val baseVer = "0.4.3"
val openurp_base_api = "org.openurp.base" % "openurp-base-api" % apiVer
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
    libraryDependencies ++= Seq(beangle_webmvc_support,beangle_data_orm,beangle_ems_app),
    libraryDependencies ++= Seq(openurp_base_api,openurp_edu_api,openurp_stater_web),
    libraryDependencies ++= Seq(beangle_serializer_text,openurp_base_tag)
  )
lazy val webapp = (project in file("webapp"))
  .enablePlugins(WarPlugin,UndertowPlugin,TomcatPlugin)
  .settings(
    name := "openurp-edu-course-webapp",
    common,
    libraryDependencies ++= Seq(logback_classic,hibernate_jcache)
  ).dependsOn(web)

publish / skip := true
