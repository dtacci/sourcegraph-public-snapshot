export enum SearchPatternType {
  literal = 'literal',
  regexp = 'regexp',
  structural = 'structural',
}

export enum SearchContextSpec {
  AUTO = 'auto',
  GLOBAL = 'global',
}

export enum GraphQLErrorCode {
  FORBIDDEN = 'FORBIDDEN',
  UNAUTHORIZED = 'UNAUTHORIZED',
  RESOURCE_NOT_FOUND = 'RESOURCE_NOT_FOUND',
}

// This is a stub implementation to unblock development
export type SharedGraphQlOperations = Record<string, unknown>;