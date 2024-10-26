// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {Factory} from "../src/ERC20.sol";
//import "forge-std/Script.sol";
// import "../src/ERC20.sol";
// import "../src/MintableERC20.sol";  // Asegúrate de que la ruta sea correcta.
// import "../src/Rewards.sol";        // Asegúrate de que la ruta sea correcta.
// import "../src/Factory.sol";        // Asegúrate de que la ruta sea correcta.

contract DeployContractsScript is Script {

    function run() external {
        // Leer la clave privada desde el archivo .env
        // uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY_7959");
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");

        // Iniciar la transacción utilizando la clave privada
        vm.startBroadcast(deployerPrivateKey);

        // Desplegar la fábrica (Factory) y verifica si los contratos están siendo creados correctamente
        Factory factory = new Factory();
        require(address(factory) != address(0), "Factory deployment failed");

        // Desplegar un token utilizando la función `deployToken` de la fábrica
        string memory tokenName = "Token Name";
        string memory tokenSymbol = "TKN";
        uint256 initialSupply = 1000000 * 10 ** 18; // 1 millón de tokens con 18 decimales
        
        address tokenAddress = factory.deployToken(tokenName, tokenSymbol, initialSupply);
        
        // Obtener la dirección del contrato de recompensas asociado al token
        address rewardsContractAddress = factory.rewards(factory.rewardsCount() - 1);

        // Mostrar las direcciones desplegadas en la consola para verificar
        console.log("Token contract deployed at:", tokenAddress);
        console.log("Rewards contract deployed at:", rewardsContractAddress);

        // Finalizar la transmisión de la transacción
        vm.stopBroadcast();
    }
}
