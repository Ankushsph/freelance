// Twitter module type declarations
declare module 'twitter' {
  export interface TwitterConfig {
    consumer_key: string;
    consumer_secret: string;
    access_token_key: string;
    access_token_secret: string;
  }

  export interface TwitterResponse {
    id: number;
    id_str: string;
    text?: string;
    media_id_string?: string;
    size?: number;
  }

  export default class Twitter {
    constructor(config: TwitterConfig);
    get(endpoint: string, params?: Record<string, any>): Promise<any>;
    post(endpoint: string, params?: Record<string, any>): Promise<any>;
    stream(endpoint: string, params?: Record<string, any>): any;
  }
}
