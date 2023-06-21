"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.NonStateVarsContainsUnderscoreChecker = void 0;
const base_checker_1 = __importDefault(require("solhint/lib/rules/base-checker"));
const identifier_naming_1 = __importDefault(require("solhint/lib/common/identifier-naming"));
const DEFAULT_SEVERITY = 'warn';
const ruleId = 'non-state-vars-contains-underscore';
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
class NonStateVarsContainsUnderscoreChecker extends base_checker_1.default {
    constructor(reporter) {
        super(reporter, ruleId, meta);
        this.inStateVariableDeclaration = false;
        this.inEventDefinition = false;
        this.inErrorDefinition = false;
        this.inStructDefinition = false;
    }
    hasTrailingUnderscore(text) {
        return text && text[text.length - 1] === '_';
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
        if ((identifier_naming_1.default.hasLeadingUnderscore(node.name) || this.hasTrailingUnderscore(node.name)) !== shouldHaveLeadingOrTrailingUnderscore) {
            this._error(node, node.name, shouldHaveLeadingOrTrailingUnderscore);
        }
    }
    _error(node, name, shouldHaveLeadingOrTrailingUnderscore) {
        this.error(node, `'${name}' ${shouldHaveLeadingOrTrailingUnderscore ? 'should' : 'should not'} start or end with _`);
    }
}
exports.NonStateVarsContainsUnderscoreChecker = NonStateVarsContainsUnderscoreChecker;
//# sourceMappingURL=non-state-vars-contains-underscore.js.map