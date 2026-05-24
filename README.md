# 📦 Hướng dẫn chạy dự án Blockchain (Hardhat)

## 🚀 Khởi tạo dự án

```bash
npx hardhat --init
```

---

## ⚙️ Hướng dẫn chạy project

### **Bước 1: Clone project**

```bash
git clone <repository-url>
```

### **Bước 2: Di chuyển vào thư mục project**

```bash
cd <ten-project>
```

### **Bước 3: Cài đặt dependencies**

```bash
npm install
```

---

### **Bước 4: Compile smart contract**

```bash
npx hardhat compile
```

✅ Nếu thành công sẽ hiển thị:

```
Compiled successfully
```

---

### **Bước 5: Chạy blockchain local**

```bash
npx hardhat node
```

📌 Kết quả:

```
Started HTTP and WebSocket JSON-RPC server at http://127.0.0.1:8545/
```

👉 Ý nghĩa:

* Tạo blockchain local
* Sinh ra **20 tài khoản test**
* Mỗi tài khoản có **private key** để sử dụng

---

### **Bước 6: Deploy smart contract**

(Mở terminal mới)

```bash
npx hardhat run scripts/deploy.ts --network localhost
```

✅ Nếu thành công:

```
Deployed at: 0x...
```

---

### **Bước 7: Chạy test (nếu có)**

```bash
npx hardhat test
```

---

## 📌 Quy trình chuẩn

```
1. npm install
2. npx hardhat compile
3. npx hardhat node
4. npx hardhat run scripts/deploy.ts --network localhost
5. npx hardhat test
```

---

# 📄 Mô tả Smart Contract: RentalContractRegistry

## 🧠 Mục đích

Smart contract này dùng để:

* Lưu trữ thông tin hợp đồng thuê (rental contract)
* Đảm bảo mỗi hợp đồng chỉ được đăng ký **một lần duy nhất**
* Lưu **hash của hợp đồng** lên blockchain để đảm bảo tính toàn vẹn dữ liệu

---

## 🏗️ Cấu trúc contract

### 1. Struct `ContractData`

```solidity
struct ContractData {
    bytes32 contractHash;
    bool exists;
}
```

👉 Ý nghĩa:

* `contractHash`: hash của hợp đồng (dùng để xác minh dữ liệu)
* `exists`: kiểm tra hợp đồng đã tồn tại hay chưa

---

### 2. Mapping lưu trữ dữ liệu

```solidity
mapping(string => ContractData) public contracts;
```

👉 Ý nghĩa:

* Key: `contractId` (string)
* Value: thông tin hợp đồng (`ContractData`)

📌 Cho phép:

* Truy xuất nhanh theo `contractId`

---

### 3. Hàm `registerContract`

```solidity
function registerContract(string memory contractId, bytes32 contractHash) public {
    require(!contracts[contractId].exists, "Already exists");

    contracts[contractId] = ContractData({
        contractHash: contractHash,
        exists: true
    });
}
```

---

## ⚙️ Chức năng chính

### ✅ Đăng ký hợp đồng

* Nhận vào:

  * `contractId`: mã hợp đồng
  * `contractHash`: hash của nội dung hợp đồng

* Kiểm tra:

  * Nếu hợp đồng đã tồn tại → ❌ reject (`Already exists`)

* Nếu chưa tồn tại:

  * Lưu vào blockchain
  * Đánh dấu `exists = true`

---

## 🔒 Tính năng bảo mật

* ❌ Không cho phép ghi đè dữ liệu
* ✅ Đảm bảo mỗi contractId là duy nhất
* ✅ Hash giúp xác minh tính toàn vẹn của hợp đồng

---

## 💡 Use case thực tế

* Backend tạo hợp đồng → generate hash
* Gửi lên blockchain qua `registerContract`
* Sau này:

  * So sánh hash → kiểm tra hợp đồng có bị sửa hay không

---

## 🔥 Tóm tắt

Contract này đóng vai trò:

> “Sổ cái lưu trữ hash của hợp đồng thuê, đảm bảo tính minh bạch và không thể thay đổi”

---


npx hardhat run scripts/deploy.ts --network sepolia