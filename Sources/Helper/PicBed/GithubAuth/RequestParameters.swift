//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/5/14.
//

import Foundation

public enum ResponseHeaderFields: String {
    case contentType = "Content-Type"
}

public enum RequestHeaderFields: String {
    case acceptCharset = "Accept-Charset"
    case acceptEncoding = "Accept-Encoding"
    case acceptLanguage = "Accept-Language"
    case authorization = "Authorization"
    case contentType = "Content-Type"
    case expect = "Expect"
    case from = "From"
    case host = "Host"
    case ifMatch = "If-Match"
    case ifModifiedSince = "If-Modified-Since"
    case ifNoneMatch = "If-None-Match"
    case ifRange = "If-Range"
    case ifUnmodifiedSince = "If-Unmodified-Since"
    case maxForwards = "Max-Forwards"
    case proxyAuthorization = "Proxy-Authorization"
    case range = "Range"
    case referer = "Referer"
    case te = "TE"
    case userAgent = "User-Agent"
}

public enum RequestMethod: String {
    case OPTIONS
    case GET
    case HEAD
    case POST
    case PATCH
    case PUT
    case DELETE
    case TRACE
    case CONNECT
}
