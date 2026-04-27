# 🚀 Protocolo Descentralizado – MVP

MVP funcional de um protocolo descentralizado que integra token ERC-20, NFT (soulbound), staking com recompensa dinâmica via Chainlink e governança simplificada. O frontend é uma única página HTML que se conecta à rede Sepolia via MetaMask, podendo ser hospedada no IPFS.

---

## 📌 Problema Resolvido

Comunidades de criadores e projetos Web3 necessitam de mecanismos descentralizados para **engajar membros**, **recompensar participação** e **decidir coletivamente** os rumos do ecossistema.  
Este protocolo oferece:

- Um token fungível (ERC-20) como unidade de valor e governança.
- NFTs intransferíveis que representam conquistas/badges.
- Staking para incentivar o compromisso de longo prazo, com recompensas ajustadas pelo preço do ETH/USD.
- Uma DAO básica onde os detentores de token votam em propostas.

Tudo isso com segurança, transparência e controle descentralizado.

---

## 🧱 Arquitetura
┌──────────────┐
│ MetaMask │
└──────┬───────┘
│
┌──────▼───────┐
│ Frontend │ (HTML + ethers.js)
│ (IPFS) │
└──────┬───────┘
│ ethers.js
┌────────────────┼────────────────┐
│ │ │
┌──────▼──────┐ ┌──────▼──────┐ ┌──────▼──────┐
│ MeuToken │ │ MeuNFT │ │ Governanca │
│ (ERC-20) │ │ (ERC-721) │ │ DAO │
└──────┬──────┘ └──────┬──────┘ └──────┬──────┘
│ │ │
└────────────────┼────────────────┘
│
┌──────▼──────┐
│ Staking │ (recompensa + oráculo)
│ Chainlink │
│ Price Feed │
└─────────────┘

text

### Contratos (Solidity ^0.8.19 + OpenZeppelin)

| Contrato        | Descrição                                                                 |
|-----------------|---------------------------------------------------------------------------|
| `MeuToken.sol`  | ERC-20 padrão, oferece `mint` apenas para o owner.                       |
| `MeuNFT.sol`    | ERC-721 soulbound (não transferível). Apenas owner e staking podem mintar.|
| `Staking.sol`   | Depósito de tokens, cálculo de recompensa baseado em tempo e preço ETH/USD, mint de NFT ao atingir limite de pontos. |
| `GovernancaDAO.sol` | Criação de propostas, votação ponderada pelo saldo de `MeuToken`, execução pelo owner. |

---

## ⚙️ Tecnologias

- **Solidity** ^0.8.19
- **OpenZeppelin** (ERC20, ERC721, Ownable, ReentrancyGuard)
- **Chainlink** Price Feed (ETH/USD)
- **ethers.js** v5
- **MetaMask**
- **Remix IDE** (compilação e deploy)
- **IPFS** (hospedagem do frontend)
- **Hardhat, Slither, Mythril** (para auditoria)

---

## 🔧 Pré‑requisitos

1. **MetaMask** instalada no navegador e configurada para a rede **Sepolia**.
2. ETH de teste na Sepolia – obtenha em [faucets](https://sepoliafaucet.com/).
3. (Opcional) [Node.js](https://nodejs.org/) e Hardhat se quiser rodar testes locais e auditoria.

---

## 📂 Estrutura do Projeto
.
├── contracts/
│ ├── MeuToken.sol
│ ├── MeuNFT.sol
│ ├── Staking.sol
│ └── GovernancaDAO.sol
├── frontend/
│ └── index.html
├── audits/
│ └── relatorio.md
└── README.md

text

---

## 🚀 Deploy na Testnet Sepolia (Remix)

### 1. Compilação

- Acesse [Remix IDE](https://remix.ethereum.org/).
- Crie os arquivos `.sol` dentro da pasta `contracts/` com os códigos fornecidos.
- Na aba **Solidity Compiler**, selecione a versão `0.8.19` e compile todos.

### 2. Deploy (ordem correta)

1. **MeuToken**  
   - `initialSupply` (ex.: 1000000) → clique em `Deploy`.  
   - **Copie o endereço gerado** (ex.: `0xToken...`).

2. **MeuNFT**  
   - Sem parâmetros → `Deploy`.  
   - **Copie o endereço**.

3. **Staking**  
   - Parâmetros do construtor:  
     - `_token`: endereço do `MeuToken`  
     - `_nft`: endereço do `MeuNFT`  
     - `_priceFeed`: `0x694AA1769357215DE4FAC081bf1f309aDC325306` (Chainlink ETH/USD Sepolia)  
   - **Copie o endereço**.

4. **GovernancaDAO**  
   - `_tokenGovernanca`: endereço do `MeuToken`  
   - **Copie o endereço**.

### 3. Configuração pós‑deploy

- No Remix, carregue o contrato `MeuNFT` pelo endereço e chame `setStakingContract`, passando o endereço do `Staking`.
- Para financiar as recompensas do Staking, carregue o contrato `MeuToken` e chame `transfer` para enviar uma quantidade de tokens para o endereço do `Staking`, ou use a função `fund` do próprio Staking (lembre-se de antes aprovar o gasto).

---

## 🌐 Frontend (HTML + ethers.js)

O arquivo `frontend/index.html` contém toda a interface. Ele deve ser atualizado com os endereços e ABIs dos contratos.

### Passos para configurar o frontend:

1. Após o deploy, no Remix, vá até a aba **Solidity Compiler** e, para cada contrato, clique no botão **ABI** para copiar o JSON.
2. Abra o `index.html` e cole:
   - Os endereços nas variáveis `TOKEN_ADDR`, `NFT_ADDR`, `STAKING_ADDR`, `DAO_ADDR`.
   - As ABIs nos arrays `tokenABI`, `nftABI`, `stakingABI`, `daoABI`.
3. Salve o arquivo.

### Executando localmente ou no IPFS

- **Localmente:** basta abrir o `index.html` no navegador (com MetaMask instalada).
- **No IPFS:** faça upload do arquivo em serviços como [Pinata](https://pinata.cloud) ou [web3.storage](https://web3.storage).  
  Exemplo: `https://gateway.pinata.cloud/ipfs/<seu-CID>`

---

## 🧪 Interação com o Protocolo

1. **Conectar MetaMask** – clique no botão da página.
2. **Mintar NFT** (apenas owner do contrato) – insira um endereço e clique em "Mint NFT".
3. **Fazer Staking** – insira uma quantidade, clique em "Stake" (aprovação automática).
4. **Sacar/Recompensa** – insira a quantidade a retirar e clique em "Sacar/Recompensa".
5. **Resgatar NFT por pontos** – clique em "Resgatar NFT". Requer 1000 pontos acumulados.
6. **Governança** – insira o ID da proposta (gerada via Remix pelo owner) e vote SIM ou NÃO.

---

## 🛡️ Segurança e Auditoria

### Medidas aplicadas nos contratos

- **Reentrancy:** uso de `nonReentrant` em funções que envolvem transferências (`stake`, `withdraw`, `claimNFT`, `vote`).
- **Controle de acesso:** `Ownable` restringe funções críticas.
- **SafeMath automático** com Solidity ^0.8.x (overflow/underflow revertidos).

### Ferramentas de auditoria

```bash
# Instale as dependências (Python e pip)
pip install slither-analyzer mythril

# Execute no diretório dos contratos (após compilar com Hardhat ou usando o JSON do Remix)
slither .
myth analyze contracts/Staking.sol
Relatório de auditoria resumido (audits/relatorio.md)

Vulnerabilidade	Severidade	Descrição	Recomendação
Centralização de privilégios	Média	O owner pode remintar tokens sem limite.	Migrar para multisig.
Dependência de oráculo simples	Baixa	A leitura do preço ETH/USD pode sofrer oscilações bruscas.	Implementar TWAP.
Falta de fundo automático	Baixa	Se o contrato de staking ficar sem saldo, saques falham.	Criar sistema de emissão de recompensas via mint.
🌍 Testnet Utilizada
Sepolia (chain ID 11155111).
Contratos implantados e verificados na rede pública de testes Ethereum.

🔮 Possíveis Melhorias
Implementar delegação de votos e período de lock na DAO.

Adicionar suporte a múltiplos tokens de staking.

Migrar para oráculo com TWAP (média temporal).

Frontend mais amigável (React) e com notificações.

Deploy em outras EVMs (Polygon, BNB Chain).

📄 Licença
Este projeto está sob a licença MIT. Veja o arquivo LICENSE (se existir) para mais detalhes.

