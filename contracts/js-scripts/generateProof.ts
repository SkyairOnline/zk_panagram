import { Noir } from '@noir-lang/noir_js';
import { ethers } from 'ethers';
import { UltraHonkBackend } from '@aztec/bb.js';
import { fileURLToPath } from 'url';
import path from 'path';
import fs from 'fs';

// get the circuit file
const circuitPath = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../../circuits/target/zk_panagram.json');
const circuit = JSON.parse(fs.readFileSync(circuitPath, 'utf8'));

export default async function generateProof() {
    const inputsArray = process.argv.slice(2);
    try {
        // initialize the Noir with circuit
        const noir = new Noir(circuit);
        // initialize the backend using the circuit bytecode
        const backend = new UltraHonkBackend(circuit.bytecode, { threads: 1 });
        // create the inputs
        const inputs = {
            // Private inputs
            guess_hash: inputsArray[0],
            // Public Inputs
            answer_hash: inputsArray[1],
            address: inputsArray[2],
        }
        // Execute the circuit with the inputs to create the witness
        const { witness } = await noir.execute(inputs);
        // Generate the proof (using the backend) with the witness
        const originalLog = console.log; // Save the original console.log
        console.log = () => {}; // Suppress console.log in the backend
        const { proof } = await backend.generateProof(witness, { keccak: true });
        console.log = originalLog; // Restore the original console.log
        // ABI Encode the proof to return it in a format that can be used in the contract
        const proofEncoded = ethers.AbiCoder.defaultAbiCoder().encode(
            ["bytes"],
            [proof]
        )
        // return the proof
        return proofEncoded;
    } catch (error) {
        console.error('Error generating proof:', error);
        throw error;
    }
}

(async () => { 
    generateProof().then((proof) => {
        process.stdout.write(proof);
        process.exit(0);
    }).catch((error) => {
        console.error('Error:', error);
        process.exit(1);
    });
})();