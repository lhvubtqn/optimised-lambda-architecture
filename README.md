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
./ssh/copy_to_all.sh ssh/constants.cfg .
```

### Cài đặt các công cụ cần thiết

#### Java
Các máy chủ cần có Java với phiên bản từ `11.0.11` trở lên.

```sh
./ssh/copy_to_all.sh libs/jdk-11.0.11_linux-x64_bin.tar.gz libs/
./ssh/run_command_on_all.sh "cd libs && tar -xf jdk-11.0.11_linux-x64_bin.tar.gz && rm jdk-11.0.11_linux-x64_bin.tar.gz"
```

#### Python 3 và pip3
Máy chủ master cần có Python 3 với phiên bản từ `3.6.9` trở lên. Chi tiết cài đặt có thể xem ở đầy: [Hướng dẫn cài đặt Python 3 và pip3 trên Ubuntu Linux](https://vinasupport.com/huong-dan-cai-dat-python-3-va-pip-3-tren-ubuntu-linux/)

#### Docker 
Máy master sử dụng [Docker](https://www.docker.com/) để chạy các tác vụ cơ sở dữ liệu và Grafana.

- Cài đặt `docker` cho Ubunbu: [Hướng dẫn cài đặt Docker Engine trên Ubuntu](https://docs.docker.com/engine/install/ubuntu/).
- Thiết lập để việc sử dụng `docker` không cần phải có lệnh `sudo`: [Quản lý Docker như một người dùng không phải root](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user).
- Cài đặt `docker-compose`: [Hướng dẫn cài đặt Docker Compose](https://docs.docker.com/compose/install/).

### Triển khai cụm Spark Standalone 

Cụm Spark Standalone bao gồm một Spark Master chạy ở máy master, và một Spark Executor chạy ở mỗi máy worker.

- Chạy Spark Master:
```sh
./ssh/copy_to_master.sh scripts/start_spark_master.sh .
./ssh/run_command_on_master.sh start_spark_master.sh
```

- Chạy các Spark Worker:
```sh
./ssh/copy_to_workers.sh scripts/start_spark_worker.sh .
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
./ssh/copy_to_master.sh scripts/start_hdfs.sh .
./ssh/run_command_on_master.sh start_hdfs.sh
```

### Triển khai Apache Kafka
Hệ thống sử dụng Apache Kafka như một trung gian truyền dữ liệu.

```sh
./ssh/copy_to_master.sh scripts/start_kafka.sh .
./ssh/run_command_on_master.sh start_kafka.sh
```

#### Chạy crawler
Hệ thống sử dụng NodeJS để viết một chương trình liên tục nhận dữ liệu từ trang [http://api.metro.net/agencies/lametro/vehicles/](http://api.metro.net/agencies/lametro/vehicles/), sau đó gửi vào trong Kafka.

```sh
./ssh/copy_to_master.sh source/crawler .
./ssh/copy_to_master.sh scripts/start_crawler.sh .
./ssh/run_command_on_master.sh start_crawler.sh
```

### Cơ sở dữ liệu
Hệ thống sử dụng TimescaleDB và Redis chạy trên nền Docker để làm cơ sở dữ liệu phục vụ truy vấn.

```sh
./ssh/copy_to_master.sh docker/databases .
./ssh/run_command_on_master.sh databases/start.sh
```

### Grafana
Hệ thống sử dụng Grafana để theo dõi trạng thái hoạt động của hệ thống, độ trễ, ...

#### Triển khai Grafana

- Chạy Grafana
```sh
./ssh/copy_to_master.sh docker/grafana .
./ssh/run_command_on_master.sh grafana/start.sh
```

- Sử dụng port-forwarding để chuyển hướng các yêu cầu đến port 3000 ở máy local đến máy master.
```sh
./ssh/forward_master_port_to_local.sh 3000
```
Giữ cửa sổ lệnh này mở để truy cập vào Grafana ở local.

#### Thiết lập Grafana

Truy cập [http://localhost:3000](http://localhost:3000), đăng nhập bằng tên tài khoản và mật khẩu `admin`.

##### Tạo nguồn dữ liệu

- Ở thanh công cụ bên trái màn hình, chọn biểu tượng bánh răng, sau đó chọn `Data sources`.

![images/grafana-datasource-1.png](images/grafana-datasource-1.png)

- Chọn `Add data source`.

![images/grafana-datasource-2.png](images/grafana-datasource-2.png)

- Điền thông tin như hình với mục `password` là `8zr7E3SV` (được thiết lập trong [docker/databases/docker-compose.yml](docker/databases/docker-compose.yml)), sau đó chọn `Save & Test`.

![images/grafana-datasource-3.png](images/grafana-datasource-3.png)

##### Tạo trang quản lý:

- Ở thanh công cụ bên trái màn hình, chọn biểu tượng dấu cộng, sau đó chọn `Import`.

![images/grafana-dashboard-1.png](images/grafana-dashboard-1.png)

- Chọn `Upload JSON file` và chọn tập tin [docker/grafana/dashboard.json](docker/grafana/dashboard.json). Nhấn `Import` để tạo trang quản lý.

![images/grafana-dashboard-2.png](images/grafana-dashboard-2.png)

- Giao diện trang quản lý sẽ tương tự như sau:

![images/grafana-dashboard-3.png](images/grafana-dashboard-3.png)