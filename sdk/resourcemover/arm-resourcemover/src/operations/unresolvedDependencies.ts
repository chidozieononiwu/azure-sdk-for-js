/*
 * Copyright (c) Microsoft Corporation.
 * Licensed under the MIT License.
 *
 * Code generated by Microsoft (R) AutoRest Code Generator.
 * Changes may cause incorrect behavior and will be lost if the code is
 * regenerated.
 */

import * as msRest from "@azure/ms-rest-js";
import * as Models from "../models";
import * as Mappers from "../models/unresolvedDependenciesMappers";
import * as Parameters from "../models/parameters";
import { ResourceMoverServiceAPIContext } from "../resourceMoverServiceAPIContext";

/** Class representing a UnresolvedDependencies. */
export class UnresolvedDependencies {
  private readonly client: ResourceMoverServiceAPIContext;

  /**
   * Create a UnresolvedDependencies.
   * @param {ResourceMoverServiceAPIContext} client Reference to the service client.
   */
  constructor(client: ResourceMoverServiceAPIContext) {
    this.client = client;
  }

  /**
   * Gets a list of unresolved dependencies.
   * @param resourceGroupName The Resource Group Name.
   * @param moveCollectionName The Move Collection Name.
   * @param [options] The optional parameters
   * @returns Promise<Models.UnresolvedDependenciesGetResponse>
   */
  get(resourceGroupName: string, moveCollectionName: string, options?: Models.UnresolvedDependenciesGetOptionalParams): Promise<Models.UnresolvedDependenciesGetResponse>;
  /**
   * @param resourceGroupName The Resource Group Name.
   * @param moveCollectionName The Move Collection Name.
   * @param callback The callback
   */
  get(resourceGroupName: string, moveCollectionName: string, callback: msRest.ServiceCallback<Models.UnresolvedDependencyCollection>): void;
  /**
   * @param resourceGroupName The Resource Group Name.
   * @param moveCollectionName The Move Collection Name.
   * @param options The optional parameters
   * @param callback The callback
   */
  get(resourceGroupName: string, moveCollectionName: string, options: Models.UnresolvedDependenciesGetOptionalParams, callback: msRest.ServiceCallback<Models.UnresolvedDependencyCollection>): void;
  get(resourceGroupName: string, moveCollectionName: string, options?: Models.UnresolvedDependenciesGetOptionalParams | msRest.ServiceCallback<Models.UnresolvedDependencyCollection>, callback?: msRest.ServiceCallback<Models.UnresolvedDependencyCollection>): Promise<Models.UnresolvedDependenciesGetResponse> {
    return this.client.sendOperationRequest(
      {
        resourceGroupName,
        moveCollectionName,
        options
      },
      getOperationSpec,
      callback) as Promise<Models.UnresolvedDependenciesGetResponse>;
  }

  /**
   * Gets a list of unresolved dependencies.
   * @param nextPageLink The NextLink from the previous successful call to List operation.
   * @param [options] The optional parameters
   * @returns Promise<Models.UnresolvedDependenciesGetNextResponse>
   */
  getNext(nextPageLink: string, options?: Models.UnresolvedDependenciesGetNextOptionalParams): Promise<Models.UnresolvedDependenciesGetNextResponse>;
  /**
   * @param nextPageLink The NextLink from the previous successful call to List operation.
   * @param callback The callback
   */
  getNext(nextPageLink: string, callback: msRest.ServiceCallback<Models.UnresolvedDependencyCollection>): void;
  /**
   * @param nextPageLink The NextLink from the previous successful call to List operation.
   * @param options The optional parameters
   * @param callback The callback
   */
  getNext(nextPageLink: string, options: Models.UnresolvedDependenciesGetNextOptionalParams, callback: msRest.ServiceCallback<Models.UnresolvedDependencyCollection>): void;
  getNext(nextPageLink: string, options?: Models.UnresolvedDependenciesGetNextOptionalParams | msRest.ServiceCallback<Models.UnresolvedDependencyCollection>, callback?: msRest.ServiceCallback<Models.UnresolvedDependencyCollection>): Promise<Models.UnresolvedDependenciesGetNextResponse> {
    return this.client.sendOperationRequest(
      {
        nextPageLink,
        options
      },
      getNextOperationSpec,
      callback) as Promise<Models.UnresolvedDependenciesGetNextResponse>;
  }
}

// Operation Specifications
const serializer = new msRest.Serializer(Mappers);
const getOperationSpec: msRest.OperationSpec = {
  httpMethod: "GET",
  path: "subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Migrate/moveCollections/{moveCollectionName}/unresolvedDependencies",
  urlParameters: [
    Parameters.subscriptionId,
    Parameters.resourceGroupName,
    Parameters.moveCollectionName
  ],
  queryParameters: [
    Parameters.dependencyLevel,
    Parameters.orderby,
    Parameters.apiVersion,
    Parameters.filter
  ],
  headerParameters: [
    Parameters.acceptLanguage
  ],
  responses: {
    200: {
      bodyMapper: Mappers.UnresolvedDependencyCollection
    },
    default: {
      bodyMapper: Mappers.CloudError
    }
  },
  serializer
};

const getNextOperationSpec: msRest.OperationSpec = {
  httpMethod: "GET",
  baseUrl: "https://management.azure.com",
  path: "{nextLink}",
  urlParameters: [
    Parameters.nextPageLink
  ],
  queryParameters: [
    Parameters.dependencyLevel,
    Parameters.orderby,
    Parameters.apiVersion,
    Parameters.filter
  ],
  headerParameters: [
    Parameters.acceptLanguage
  ],
  responses: {
    200: {
      bodyMapper: Mappers.UnresolvedDependencyCollection
    },
    default: {
      bodyMapper: Mappers.CloudError
    }
  },
  serializer
};
