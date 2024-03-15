import { assert } from "chai";
import {
  ContractFunctionExecutionError,
  ContractFunctionRevertedError,
  RawContractError,
} from "viem";

export const fixRevertError = (err: unknown) => {
  assert(err instanceof ContractFunctionExecutionError);

  const { abi, functionName, message, shortMessage } = err;

  const { data } = (err.walk((err) => "data" in (err as Error)) ||
    err.walk()) as RawContractError;

  return new ContractFunctionRevertedError({
    abi,
    data: typeof data === "object" ? data.data : data,
    functionName,
    message: shortMessage ?? message,
  });
};

export const fixRevertErrorIfNeeded = (err: unknown) => {
  if (err instanceof ContractFunctionRevertedError) return err;
  return fixRevertError(err);
};
