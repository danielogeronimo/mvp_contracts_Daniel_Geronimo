async function main() {
    // 1. Deploy ERC-20
    const Brick = await ethers.getContractFactory("BrickToken");
    const brick = await Brick.deploy();

    // 2. Deploy NFT
    const NFT = await ethers.getContractFactory("PropertyNFT");
    const nft = await NFT.deploy();

    // 3. Deploy DAO (Passando endereços dos anteriores + Oráculo Sepolia)
    const DAO = await ethers.getContractFactory("RealEstateDAO");
    const dao = await DAO.deploy(
        brick.target, 
        nft.target, 
        "0x694AA1769357215DE4FAC081bf1f309aDC325306" // ETH/USD Sepolia
    );

    // 4. Transferir Ownership do NFT para a DAO (para ela poder mintar)
    await nft.transferOwnership(dao.target);

    console.log("Sistema Modular Implantado!");
}
