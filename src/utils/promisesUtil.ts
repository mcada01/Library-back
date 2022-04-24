export class PromisesUtil {
  private _promise: Promise<any>;
  private _callBack: FunctionCallback;
  private _callBackBad: FunctionCallback;

  constructor(
    promise: Promise<any>,
    callback?: FunctionCallback,
    callbackBad?: FunctionCallback,
  ) {
    this._promise = promise;
    this._callBack = callback;
    this._callBackBad = callbackBad;
  }

  public static callAllPromise(listPromises: Array<PromisesUtil>): void {
    let promises: Array<Promise<any>> = listPromises.map((p) => p.promise);
    Promise.all(promises);
  }

  get promise(): Promise<any> {
    return this._promise;
  }

  set promise(value: Promise<any>) {
    this._promise = value;
  }
}

type FunctionCallback = (res: any) => void;
