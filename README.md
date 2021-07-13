# Hướng dẫn cụ thể triển khai hệ thống

Hệ thống sử dụng trong luận văn được cài đặt trên ba máy chủ ảo của Microsoft Azure, trong đó một máy chịu trách nhiệm chạy các tác vụ điều khiển và cơ sở dữ liệu, hai máy còn lại chạy tiến trình Spark Executor và HDFS DataNode. Chi tiết các tác vụ được trình bày trong hình sau:

![Deploy map](./images/deploy-map.png)

## Triển khai các tác vụ

### Thiết lập các thông số cần thiết

Ở tệp tin [ssh/constants.cfg](./ssh/constants.cfg), điều chỉnh các thông số cho phù hợp với môi trường triển khai hệ thống. Trong đó:

- `MASTER_ADDRESS`: Địa chỉ public của máy master.
- `MASTER_INTERNAL_ADDRESS`: Địa chỉ nội bộ của máy master. Các máy worker cần phân giải được địa chỉ này và truy cập được tất cả các port sử dụng địa chỉ này.
- `WORKER_NUM`: Số lượng máy worker.
- `WORKER_ADDRESS_<i>`: Địa chỉ máy worker thứ `i`.
- `WORKER_INTERNAL_ADDRESS_<i>`: Địa chỉ nội bộ của máy worker thứ `i`. Máy master cần phân giải được địa chỉ này và truy cập được tất cả các port sử dụng địa chỉ này.
- `SSH_USERNAME`: Tên tài khoản dùng để truy cập các máy chủ.
- `SSH_KEY_PATH`: Đường dẫn đến tập tin khoá bảo mật (private key) để truy cập đến các máy chủ. Trên các máy chủ cần có các tệp khóa công khai (public key) để xác nhận sự truy cập.

Xem thêm cách tạo khóa và truy cập máy chủ từ xa tại: [Hướng dẫn cách truy cập các máy chủ tử xa sử dụng ssh và khóa](https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-linux-server).

Cuối cùng, copy tập tin [ssh/constants.cfg](./ssh/constants.cfg) lên các máy chủ:
```sh
./ssh/copy_to_all.sh ./ssh/constants.cfg .
```

### Cài đặt các công cụ cần thiết

#### Java
Các máy chủ cần có Java với phiên bản từ `11.0.11` trở lên.

```sh
./ssh/copy_to_all.sh ./libs/jdk-11.0.11_linux-x64_bin.tar.gz libs/
./ssh/run_command_on_all.sh "cd libs && tar -xf jdk-11.0.11_linux-x64_bin.tar.gz && rm jdk-11.0.11_linux-x64_bin.tar.gz"
```

#### Docker 
Máy master sử dụng [Docker](https://www.docker.com/) để chạy các tác vụ cơ sở dữ liệu và Grafana.

- Cài đặt `docker` cho Ubunbu: [Hướng dẫn cài đặt Docker Engine trên Ubuntu](https://docs.docker.com/engine/install/ubuntu/).
- Thiết lập để việc sử dụng `docker` không cần phải có lệnh `sudo`: [Quản lý Docker như một người dùng không phải root](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user).
- Cài đặt `docker-compose`: [Hướng dẫn cài đặt Docker Compose](https://docs.docker.com/compose/install/).
### Triển khai cụm Spark Standalone 

Cụm Spark Standalone bao gồm một Spark Master chạy ở máy master, và một Spark Executor chạy ở mỗi máy worker.

- Chạy Spark Master:
```sh
./ssh/copy_to_master.sh ./scripts/start_spark_master.sh .
./ssh/run_command_on_master.sh start_spark_master.sh
```

- Chạy các Spark Worker:
```sh
./ssh/copy_to_workers.sh ./scripts/start_spark_worker.sh .
./ssh/run_command_on_workers.sh start_spark_worker.sh
```

### Triển khai hệ thống quản lý tập tin phân tán HDFS
HDFS gồm một tác vụ NameNode trên máy master và một tác vụ DataNode trên mỗi máy worker.

Để triển khai HDFS trên các DataNode, máy chủ master cần phải truy cập được vào các máy chủ worker bằng SSH.

- Tạo ra một cặp khóa:
```sh
ssh-keygen -b 4096 -t rsa -f ssh/id_rsa -q -N ""
```

- Copy khóa bảo mật lên máy master:
```sh
./ssh/copy_to_master.sh "ssh/id_rsa ssh/id_rsa.pub" .ssh/
./ssh/run_command_on_master.sh "cat .ssh/id_rsa.pub >> .ssh/authorized_keys"
```

- Copy khóa công khai lên các máy worker và cho phép master truy cập:
```sh
./ssh/copy_to_workers.sh ssh/id_rsa.pub .ssh/
./ssh/run_command_on_workers.sh "cat .ssh/id_rsa.pub >> .ssh/authorized_keys"
```

- Config các máy chủ:
```
./ssh/copy_to_all.sh scripts/config_hdfs.sh .
./ssh/run_command_on_all.sh config_hdfs.sh
```

- Chạy HDFS:
```
./ssh/copy_to_master.sh ./scripts/start_hdfs.sh .
./ssh/run_command_on_master.sh start_hdfs.sh
```
## Architecture

The abstract architecture with used technologies is shown as below:
![Architecture](./images/architecture-horizontal.png)
The architecture includes:

- **Kafka**: The message broker, where services or devices data are sent to. Those data will then be pushed to **HDFS** for later batch processing, sent to **Streaming Layer** for immediate processing and result.

- **HDFS**: Distributed, fault tolerant file system. Kafka raw messages (raw data) & batch processing result are sent to here. This technology is chosen because it fits perfectly with Apache Spark.

- **Batch Layer**: Apache Spark SQL. This layer is scheduled to load all raw data from HDFS, dedupes and processes them periodically. The result will be sent to a known folder on HDFS and will replace all the old data in that folder. These data will then be used to correct the result produced by **Streaming Layer**.

- **Streaming Layer**: Apache Spark Streaming. Raw data from Kafka will be sent to this layer as a continuous stream and will be processed as minibatches. After process a minibatch, the layer will check if there are new data at the known folder in HDFS. If there are, the merging process will happen, that merges result data from Batch Layer, Streaming Layer and update the Serving Layer. This will ensure that the data in Serving Layer is eventually consistent.

- **Serving Layer**: Result data are stored in this layer. The dashboard application will get data from **TimescaleDB** or **Redis** to visualize statistics. Admin can use JDBC Client (like DBeaver), Redis Client (like redis-cli) to query stats from databases directly.

### Flowchart

Overall workflow of the system is described as follow:

#### Preprocessing data

![flowchart-preprocess](./images/flowchart-preprocess.png)

#### Batch layer

![flowchart-batch-layer](./images/flowchart-batch-layer.png)

#### Stream layer

![flowchart-stream-layer](./images/flowchart-stream-layer.png)

## Performance Testing

### Test environment

### Test result
