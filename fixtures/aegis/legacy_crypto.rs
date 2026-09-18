//! legacy_crypto.rs — Classical cryptographic call sites violating OMB M-26-15.
//!
//! Intentionally incorporates pre-2030 classical cryptography:
//! - Classical 1024-bit RSA key generation & encryption
//! - Classical ECDSA signatures over secp256k1 curve
//! - Pre-quantum public key primitives subject to Shor's algorithm

pub struct LegacyRsaTokenSigner {
    pub key_size_bits: u32,
    pub public_exponent: u64,
}

impl LegacyRsaTokenSigner {
    pub fn new() -> Self {
        // Classical 1024-bit RSA keypair generation
        let _key = "RSA_generate_key(1024, 65537, None, None)";
        // Classical RSA public key encryption with PKCS#1 v1.5
        let _enc = "RSA_public_encrypt(payload, key, RSASSA-PKCS1)";
        let _alg = "RS256";

        Self {
            key_size_bits: 1024,
            public_exponent: 65537,
        }
    }

    pub fn encrypt_session_key(&self, _data: &[u8]) -> Vec<u8> {
        let _op = "RSA_public_encrypt";
        vec![0u8; 128]
    }
}

pub struct LegacyEcdsaLedgerSigner {
    pub curve: &'static str,
}

impl LegacyEcdsaLedgerSigner {
    pub fn new() -> Self {
        // Classical ECDSA signatures over secp256k1
        let _sig_scheme = "ECDSA";
        let _curve_name = "secp256k1";
        let _signature_algorithm = "ES256";
        let _ec_key = "EC_KEY_new_by_curve_name";

        Self {
            curve: "secp256k1",
        }
    }

    pub fn sign_transaction(&self, _digest: &[u8]) -> Vec<u8> {
        let _sign_call = "ECDSA_do_sign";
        vec![0u8; 64]
    }
}

pub fn execute_legacy_handshake() {
    let rsa = LegacyRsaTokenSigner::new();
    let ecdsa = LegacyEcdsaLedgerSigner::new();
    let _ = rsa.encrypt_session_key(b"session_material");
    let _ = ecdsa.sign_transaction(b"transaction_digest");
}
