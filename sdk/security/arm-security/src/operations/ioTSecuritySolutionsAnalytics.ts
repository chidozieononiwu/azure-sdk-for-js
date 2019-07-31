/*
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License. See License.txt in the project root for
 * license information.
 *
 * Code generated by Microsoft (R) AutoRest Code Generator.
 * Changes may cause incorrect behavior and will be lost if the code is
 * regenerated.
 */

import * as msRest from "@azure/ms-rest-js";
import * as Models from "../models";
import * as Mappers from "../models/ioTSecuritySolutionsAnalyticsMappers";
import * as Parameters from "../models/parameters";
import { SecurityCenterContext } from "../securityCenterContext";

/** Class representing a IoTSecuritySolutionsAnalytics. */
export class IoTSecuritySolutionsAnalytics {
  private readonly client: SecurityCenterContext;

  /**
   * Create a IoTSecuritySolutionsAnalytics.
   * @param {SecurityCenterContext} client Reference to the service client.
   */
  constructor(client: SecurityCenterContext) {
    this.client = client;
  }

  /**
   * Security Analytics of a security solution
   * @param resourceGroupName The name of the resource group within the user's subscription. The name
   * is case insensitive.
   * @param solutionName The solution manager name
   * @param [options] The optional parameters
   * @returns Promise<Models.IoTSecuritySolutionsAnalyticsGetAllResponse>
   */
  getAll(resourceGroupName: string, solutionName: string, options?: msRest.RequestOptionsBase): Promise<Models.IoTSecuritySolutionsAnalyticsGetAllResponse>;
  /**
   * @param resourceGroupName The name of the resource group within the user's subscription. The name
   * is case insensitive.
   * @param solutionName The solution manager name
   * @param callback The callback
   */
  getAll(resourceGroupName: string, solutionName: string, callback: msRest.ServiceCallback<Models.IoTSecuritySolutionAnalyticsModelList>): void;
  /**
   * @param resourceGroupName The name of the resource group within the user's subscription. The name
   * is case insensitive.
   * @param solutionName The solution manager name
   * @param options The optional parameters
   * @param callback The callback
   */
  getAll(resourceGroupName: string, solutionName: string, options: msRest.RequestOptionsBase, callback: msRest.ServiceCallback<Models.IoTSecuritySolutionAnalyticsModelList>): void;
  getAll(resourceGroupName: string, solutionName: string, options?: msRest.RequestOptionsBase | msRest.ServiceCallback<Models.IoTSecuritySolutionAnalyticsModelList>, callback?: msRest.ServiceCallback<Models.IoTSecuritySolutionAnalyticsModelList>): Promise<Models.IoTSecuritySolutionsAnalyticsGetAllResponse> {
    return this.client.sendOperationRequest(
      {
        resourceGroupName,
        solutionName,
        options
      },
      getAllOperationSpec,
      callback) as Promise<Models.IoTSecuritySolutionsAnalyticsGetAllResponse>;
  }

  /**
   * Security Analytics of a security solution
   * @param resourceGroupName The name of the resource group within the user's subscription. The name
   * is case insensitive.
   * @param solutionName The solution manager name
   * @param [options] The optional parameters
   * @returns Promise<Models.IoTSecuritySolutionsAnalyticsGetDefaultResponse>
   */
  getDefault(resourceGroupName: string, solutionName: string, options?: msRest.RequestOptionsBase): Promise<Models.IoTSecuritySolutionsAnalyticsGetDefaultResponse>;
  /**
   * @param resourceGroupName The name of the resource group within the user's subscription. The name
   * is case insensitive.
   * @param solutionName The solution manager name
   * @param callback The callback
   */
  getDefault(resourceGroupName: string, solutionName: string, callback: msRest.ServiceCallback<Models.IoTSecuritySolutionAnalyticsModel>): void;
  /**
   * @param resourceGroupName The name of the resource group within the user's subscription. The name
   * is case insensitive.
   * @param solutionName The solution manager name
   * @param options The optional parameters
   * @param callback The callback
   */
  getDefault(resourceGroupName: string, solutionName: string, options: msRest.RequestOptionsBase, callback: msRest.ServiceCallback<Models.IoTSecuritySolutionAnalyticsModel>): void;
  getDefault(resourceGroupName: string, solutionName: string, options?: msRest.RequestOptionsBase | msRest.ServiceCallback<Models.IoTSecuritySolutionAnalyticsModel>, callback?: msRest.ServiceCallback<Models.IoTSecuritySolutionAnalyticsModel>): Promise<Models.IoTSecuritySolutionsAnalyticsGetDefaultResponse> {
    return this.client.sendOperationRequest(
      {
        resourceGroupName,
        solutionName,
        options
      },
      getDefaultOperationSpec,
      callback) as Promise<Models.IoTSecuritySolutionsAnalyticsGetDefaultResponse>;
  }
}

// Operation Specifications
const serializer = new msRest.Serializer(Mappers);
const getAllOperationSpec: msRest.OperationSpec = {
  httpMethod: "GET",
  path: "subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Security/iotSecuritySolutions/{solutionName}/analyticsModels",
  urlParameters: [
    Parameters.subscriptionId,
    Parameters.resourceGroupName,
    Parameters.solutionName
  ],
  queryParameters: [
    Parameters.apiVersion3
  ],
  headerParameters: [
    Parameters.acceptLanguage
  ],
  responses: {
    200: {
      bodyMapper: Mappers.IoTSecuritySolutionAnalyticsModelList
    },
    default: {
      bodyMapper: Mappers.CloudError
    }
  },
  serializer
};

const getDefaultOperationSpec: msRest.OperationSpec = {
  httpMethod: "GET",
  path: "subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Security/iotSecuritySolutions/{solutionName}/analyticsModels/default",
  urlParameters: [
    Parameters.subscriptionId,
    Parameters.resourceGroupName,
    Parameters.solutionName
  ],
  queryParameters: [
    Parameters.apiVersion3
  ],
  headerParameters: [
    Parameters.acceptLanguage
  ],
  responses: {
    200: {
      bodyMapper: Mappers.IoTSecuritySolutionAnalyticsModel
    },
    default: {
      bodyMapper: Mappers.CloudError
    }
  },
  serializer
};
