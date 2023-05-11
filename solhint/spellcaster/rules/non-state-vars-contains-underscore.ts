import BaseChecker from 'solhint/lib/rules/base-checker';
import naming from 'solhint/lib/common/identifier-naming';

const DEFAULT_SEVERITY: string = 'warn';

const ruleId: string = 'non-state-vars-contains-underscore';
const meta = {
  type: 'naming',
  docs: {
    description: 'Variables that are not in state or events should start or end with underscore. `i` is also excluded. Examples: `_myVar` / `myVar_`.',
    category: 'Style Guide Rules',
  },
  isDefault: true,
  recommended: true,
  defaultSetup: [DEFAULT_SEVERITY],
};

export class NonStateVarsContainsUnderscoreChecker extends BaseChecker {
  private inStateVariableDeclaration = false;
  private inEventDefinition = false;
  private inErrorDefinition = false;
  private inStructDefinition = false;

  constructor(reporter) {
    super(reporter, ruleId, meta);
  }

  hasTrailingUnderscore(text) {
    return text && text[text.length - 1] === '_'
  }

  StateVariableDeclaration() {
    this.inStateVariableDeclaration = true;
  }

  EventDefinition(node) {
    this.inEventDefinition = true;
  }

  CustomErrorDefinition(node) {
    this.inErrorDefinition = true;
  }

  'StateVariableDeclaration:exit'() {
    this.inStateVariableDeclaration = false;
  }

  'EventDefinition:exit'() {
    this.inEventDefinition = false;
  }

  'CustomErrorDefinition:exit'() {
    this.inErrorDefinition = false;
  }

  StructDefinition(node) {
    this.inStructDefinition = true;
  }

  'StructDefinition:exit'() {
    this.inStructDefinition = false;
  }

  VariableDeclaration(node) {
    if (!this.inStateVariableDeclaration) {
      const shouldHaveLeadingOrTrailingUnderscore = !this.inStructDefinition && !this.inEventDefinition && !this.inErrorDefinition;
      this.validateName(node, shouldHaveLeadingOrTrailingUnderscore);
    }
    else {
      // State variables should not have leading or trailing underscore
      this.validateName(node, false);
    }
  }

  validateName(node, shouldHaveLeadingOrTrailingUnderscore) {
    if (node.name === null || node.name === 'i') {
      return;
    }

    if ((naming.hasLeadingUnderscore(node.name) || this.hasTrailingUnderscore(node.name)) !== shouldHaveLeadingOrTrailingUnderscore) {
      this._error(node, node.name, shouldHaveLeadingOrTrailingUnderscore);
    }
  }

  _error(node, name, shouldHaveLeadingOrTrailingUnderscore) {
    this.error(node, `'${name}' ${shouldHaveLeadingOrTrailingUnderscore ? 'should' : 'should not'} start or end with _`);
  }
}