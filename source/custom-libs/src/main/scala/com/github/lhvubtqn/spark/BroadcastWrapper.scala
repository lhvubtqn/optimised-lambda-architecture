package com.github.lhvubtqn.spark

import java.io.{File, FileNotFoundException}
import java.net.URI

import com.sun.org.apache.xml.internal.security.signature.reference.ReferenceData
import org.apache.spark.api.java.JavaSparkContext
import org.apache.spark.broadcast.Broadcast
import java.util.{Calendar, Date}

import org.apache.hadoop.conf.Configuration
import org.apache.hadoop.fs.{FileSystem, Path}
import org.apache.hadoop.mapred.FileSplit
import org.apache.hadoop.util.StringUtils
import org.apache.spark.sql.expressions.UserDefinedFunction
import org.apache.spark.sql.{DataFrame, Row, SparkSession}
import org.apache.spark.sql.functions._
import org.apache.spark.sql.types._

/**
 * Created by vulh4
 * Date: 05/07/2021
 * Time: 00:43
 */
object BroadcastWrapper {
  val UPDATE_DELTA_MS = 60000

  private val obj = new BroadcastWrapper

  def getInstance: BroadcastWrapper = obj
}

/**
 * Created by vulh4
 * Date: 05/07/2021
 * Time: 00:43
 */
class BroadcastWrapper extends Serializable {

  private val aliasRouteId = Map.apply(
    17->16, 48->10, 37->14, 38->35, 52->51, 79->78, 91->90, 240->150, 163->162, 181->180,
    215->211, 245->244, 267->264, 243->242, 489->487, 656->237, 687->686, 950->910
  )
  private val replaceAliasRouteId = udf[Int, Int](
    (r: Int) => if (aliasRouteId.contains(r)) aliasRouteId(r) else r
  )

  private val combineMap = udf(
    (maps: Seq[Map[String, Row]]) => Map.apply(maps.map((map: Map[String, Row]) => map.last):_*),
    new MapType(
      StringType,
      new StructType()
        .add("velocity", DoubleType, nullable = true)
        .add("velocity_sign", IntegerType, nullable = true),
      true
    )
  )

  private var broadcastVar: Broadcast[Map[String, Row]] = _
  private var lastUpdatedTime: Date = _

  def getVelocityUDF: UserDefinedFunction = {
    udf(
      (routeId: Int, direction: Int, dayType: Int) => {
        val routeVelocity = broadcastVar.value
        val key = routeId + "_" + direction + "_" + dayType
        if (routeVelocity.contains(key)) routeVelocity(key) else routeVelocity.last._2
      },
      new StructType()
        .add("velocity", DoubleType, nullable = true)
        .add("velocity_sign", IntegerType, nullable = true)
    )
  }

  def updateBroadcastVar(jsc: JavaSparkContext, spark: SparkSession, jsonPath: String): Unit = {
    val lastModifiedTime = if (jsonPath.startsWith("hdfs://")) {
      val uri = new URI(jsonPath)
      val fs = FileSystem.get(uri, jsc.hadoopConfiguration())
      new Date(fs.getFileStatus(new Path(uri.getPath)).getModificationTime)
    } else {
      var file = new File(jsonPath)
      if (file.isDirectory) file = file.listFiles()(0)
      new Date(file.lastModified)
    }

    if (lastUpdatedTime != null && lastModifiedTime.getTime - lastUpdatedTime.getTime < BroadcastWrapper.UPDATE_DELTA_MS) return
    else lastUpdatedTime = lastModifiedTime

    val data = getData(spark, jsonPath)
    broadcastVar = jsc.broadcast(data)
  }

  private def getData(spark: SparkSession, jsonPath: String): Map[String, Row] = {
    spark
      .read
      .json(jsonPath)
      .withColumn("route_id", replaceAliasRouteId(col("route_id")))
      .withColumn("velocity_sign", col("velocity_sign").cast("int"))
      .select(
        combineMap(
          collect_list(
            map(
              concat_ws(
                "_",
                col("route_id"),
                col("direction"),
                col("day_type")
              ),
              struct(
                col("velocity"),
                col("velocity_sign")
              )
            )
          )
        ).alias("map")
      )
      .collect()(0)(0)
      .asInstanceOf[Map[String, Row]]
  }
}
