/**
 * Canary fixture: Hardcoded production API credentials.
 * Triggers Snip SecretLeak (Critical).
 */

export interface StripeConfig {
  liveSecretKey: string;
  anthropicKey: string;
}

export const apiConfig: StripeConfig = {
  liveSecretKey: "sk_live_51M0abc1234567890abcdefghijklmnopqrstuvwxyz",
  anthropicKey: "sk-ant-api03-abcdefghijklmnopqrstuvwxyz1234567890",
};
