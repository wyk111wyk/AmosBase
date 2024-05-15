//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/5/14.
//

import Foundation

public enum GithubScopes : String {
    case user = "user"
    case userEmail = "user:email"
    case userFollow = "user:follow"
    case publicRepo = "public_repo"
    case repo = "repo"
    case repoDeployment = "repo_deployment"
    case repoStatus = "repo:status"
    case deleteRepo = "delete_repo"
    case notifications = "notifications"
    case gist = "gist"
    case readRepoHook = "read:repo_hook"
    case writeRepoHook = "write:repo_hook"
    case adminRepoHook = "admin:repo_hook"
    case adminOrgHook = "admin:org_hook"
    case readOrg = "read:org"
    case writeOrg = "write:org"
    case adminOrg = "admin:org"
    case readPublicKey = "read:public_key"
    case writePublicKey = "write:public_key"
    case adminPublicKey = "admin:public_key"
    case readGPGKey = "read:gpg_key"
    case writeGPGKey = "write:gpg_key"
    case adminGPGKey = "admin:gpg_key"
}
