import BaseChecker from 'solhint/lib/rules/base-checker';
export declare class NonStateVarsContainsUnderscoreChecker extends BaseChecker {
    private inStateVariableDeclaration;
    private inEventDefinition;
    private inErrorDefinition;
    private inStructDefinition;
    constructor(reporter: any);
    hasTrailingUnderscore(text: any): boolean;
    StateVariableDeclaration(): void;
    EventDefinition(node: any): void;
    CustomErrorDefinition(node: any): void;
    'StateVariableDeclaration:exit'(): void;
    'EventDefinition:exit'(): void;
    'CustomErrorDefinition:exit'(): void;
    StructDefinition(node: any): void;
    'StructDefinition:exit'(): void;
    VariableDeclaration(node: any): void;
    validateName(node: any, shouldHaveLeadingOrTrailingUnderscore: any): void;
    _error(node: any, name: any, shouldHaveLeadingOrTrailingUnderscore: any): void;
}
//# sourceMappingURL=non-state-vars-contains-underscore.d.ts.map