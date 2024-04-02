interface IOption {
    urlDns: string;
    directUploadAddr: string;
    retryCount: number;
    timeout: number;
    onError: (errObj: any) => void;
    onProgress: (curFile: any) => void;
}
export declare function Uploader(options?: Partial<IOption>): any;
export {};
