import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const RentalModule = buildModule("RentalModule", (m) => {
  // Phải khớp với tên hợp đồng trong file .sol của bạn
  const rental = m.contract("RentalContractRegistry"); 

  return { rental };
});

export default RentalModule;