import org.openurp.parent.Dependencies.*
import org.openurp.parent.Settings.*
import sbt.Keys.libraryDependencies

ThisBuild / organization := "org.openurp.edu.course"
ThisBuild / version := "0.0.4-SNAPSHOT"

ThisBuild / scmInfo := Some(
  ScmInfo(
    url("https://github.com/openurp/edu-course"),
    "scm:git@github.com:openurp/edu-course.git"
  )
)

ThisBuild / developers := List(
  Developer(
    id = "chaostone",
    name = "Tihua Duan",
    email = "duantihua@gmail.com",
    url = url("http://github.com/duantihua")
  )
)

ThisBuild / description := "The OpenURP Edu Course"
ThisBuild / homepage := Some(url("http://openurp.github.io/edu-course/index.html"))
ThisBuild / resolvers += Resolver.mavenLocal

val apiVer = "0.41.7"
val starterVer = "0.3.41"
val baseVer = "0.4.39"
val eduCoreVer = "0.3.1"

val openurp_base_api = "org.openurp.base" % "openurp-base-api" % apiVer
val openurp_edu_api = "org.openurp.edu" % "openurp-edu-api" % apiVer
val openurp_edu_core = "org.openurp.edu" % "openurp-edu-core" % eduCoreVer
val openurp_stater_web = "org.openurp.starter" % "openurp-starter-web" % starterVer
val openurp_base_tag = "org.openurp.base" % "openurp-base-tag" % baseVer
val beangle_doc_html = "org.beangle.doc" % "beangle-doc-html" % "0.4.1"
lazy val root = (project in file("."))
  .enablePlugins(WarPlugin, UndertowPlugin, TomcatPlugin)
  .settings(
    name := "openurp-edu-course-webapp",
    common,
    libraryDependencies ++= Seq(beangle_ems_app),
    libraryDependencies ++= Seq(openurp_base_api, openurp_edu_api, openurp_stater_web),
    libraryDependencies ++= Seq(openurp_base_tag, beangle_doc_pdf, beangle_doc_html),
    libraryDependencies ++= Seq(logback_classic, openurp_edu_core, beangle_webmvc)
  )
