package com.github.lhvubtqn.spark

import com.redislabs.provider.redis.RedisContext
import org.apache.spark.api.java.{JavaRDD, JavaSparkContext}
import org.apache.spark.rdd.RDD
import org.apache.spark.sql.{DataFrame, Row}

/**
 * Created by vulh4
 * Date: 03/07/2021
 * Time: 20:40
 */
object Utils {
  def toRedisHashes(jsc: JavaSparkContext, jrdd: DataFrame): Unit = {
    val rc = new RedisContext(jsc.sc)
    val rdd = jrdd
      .rdd
      .collect({
        case row: Row => Tuple2(row.get(0), row.get(1))
      })
    rc.toRedisHASHes(rdd.asInstanceOf[RDD[(String, Map[String, String])]])
  }
}
