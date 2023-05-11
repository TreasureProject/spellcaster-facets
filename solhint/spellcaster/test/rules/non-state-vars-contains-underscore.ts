import assert from 'assert';
import { processStr } from '../utils/linter';
import { contractWith } from 'solhint/test/common/contract-builder';

const config = {
  rules: { 'non-state-vars-contains-underscore': 'error' },
};

describe('non-state-vars-contains-underscore', () => {
  it('should raise an error if a block variable does not contain with an underscore', () => {
    const code = contractWith('function foo() public { uint myVar; }');
    const report = processStr(code, config);
    assert.equal(report.errorCount, 1);
    assert.ok(report.messages[0].message == `'myVar' should start or end with _`);
  });

  it('should not raise an error if a block variable starts with an underscore', () => {
    const code = contractWith('function foo() public { uint _myVar; }');
    const report = processStr(code, config);

    assert.equal(report.errorCount, 0);
  });

  it('should not raise an error if a block variable ends with an underscore', () => {
    const code = contractWith('function foo() public { uint myVar_; }');
    const report = processStr(code, config);

    assert.equal(report.errorCount, 0);
  });

  it('should not raise an error if an event variable doesnt contain an underscore', () => {
    const code = contractWith('event MyEvent(bytes32 myVar);');
    const report = processStr(code, config);

    assert.equal(report.errorCount, 0);
  });

  it('should not raise an error if a custom error variable doesnt contain an underscore', () => {
    const code = contractWith('error MyError(bytes32 myVar);');
    const report = processStr(code, config);

    assert.equal(report.errorCount, 0);
  });
});