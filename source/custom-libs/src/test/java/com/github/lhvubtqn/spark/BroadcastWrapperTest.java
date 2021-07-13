package com.github.lhvubtqn.spark;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileStatus;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.util.StringUtils;

import java.io.File;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.Arrays;
import java.util.Date;

/**
 * Created by vulh4
 * Date: 05/07/2021
 * Time: 05:04
 */
class BroadcastWrapperTest {
    public static void main(String[] args) throws Exception {
        String jsonPath = "hdfs://localhost:8020/ola/aggregated_data/bus_velocities.json";
//        String jsonPath = "/home/ubuntu/Desktop/spark-thesis/optimised-lambda-architecture/lambda/storage/data/aggregated_data/bus_velocities.json";

        File file = new File(jsonPath);

        System.out.println(file.exists());
        System.out.println(Arrays.toString(file.listFiles()));

        if (file.isDirectory()) file = file.listFiles()[0];
        System.out.println(file.getPath());
        System.out.println(new Date(file.lastModified()));

        System.out.println(jsonPath.startsWith("hdfs://"));

        System.out.println(new URI(jsonPath).getPath());

        URI uri = new URI(jsonPath);
        FileSystem fs = FileSystem.get(uri, new Configuration());
        FileStatus[] status = fs.listStatus(new Path(uri.getPath()));

        System.out.println(Arrays.toString(status));
    }
}