#!/bin/bash
set -e  # Dừng script ngay lập tức nếu bất kỳ lệnh nào bị lỗi

EXPORTER_VERSION="1.9.1"

echo ">>> Đang cài đặt Node Exporter phiên bản ${EXPORTER_VERSION}..."
# 1. BẢO MẬT: Tạo user hệ thống riêng, không cho đăng nhập
# Dùng id để check trước, tránh lỗi nếu chạy lại script
id -u node_exporter &>/dev/null || sudo useradd --no-create-home --shell /bin/false node_exporter

# 2. CHUẨN BỊ: Vào tmp và tải bản mới nhất (v1.9.1)
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v${EXPORTER_VERSION}/node_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz
tar xvf node_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz

# 3. CÀI ĐẶT: Di chuyển binary vào /usr/local/bin (Chuẩn FHS cho binary)
# Dùng cp hoặc mv đều được, nhưng cp an toàn hơn nếu file đang lock
echo ">>> Đang di chuyển file binary..."
sudo cp node_exporter-${EXPORTER_VERSION}.linux-amd64/node_exporter /usr/local/bin/
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

# Dọn dẹp file rác
rm -rf node_exporter-${EXPORTER_VERSION}.linux-amd64*
rm -f node_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz

# 4. TỰ ĐỘNG HÓA: Tạo Service bằng lệnh tee (Không dùng nano)
echo ">>> Đang cấu hình Systemd Service..."
sudo tee /etc/systemd/system/node_exporter.service <<EOF
[Unit]
Description=Node Exporter
Documentation=https://github.com/prometheus/node_exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# 5. KHỞI CHẠY
sudo systemctl daemon-reload
sudo systemctl enable --now node_exporter

# 6. KIỂM TRA & FIREWALL (Nếu dùng UFW)
echo ">>> Kiểm tra trạng thái"
sudo systemctl status node_exporter --no-pager
# Mở port nếu máy chủ có tường lửa (Optional)
sudo ufw allow 9100/tcp









--------------
Quy trình chạy file:
--------------
1. Tạo file: vim node_exporter.sh
2. Chạy script với 1 trong 2 cách:
```
# Cách 1
sudo bash install_node_exporter.sh

# Cách 2
chmod +x node_exporter.sh
sudo ./node_exporter.sh
```