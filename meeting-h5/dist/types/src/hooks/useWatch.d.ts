declare type Callback<T> = (prev: T | undefined) => void;
export default function useWatch<T>(data: T, callback: Callback<T>, config?: {
    immediate: boolean;
}): void;
export {};
