//
//  URLEncoding.swift
//  JSONRequest
//
//  Created by Matt Holden on 7/28/17.
//  Copyright © 2017 Hathway. All rights reserved.
//

import Foundation

// This code is ported from Alamofire's `URLEncoding` struct:
// https://github.com/Alamofire/Alamofire/blob/5bd458ca09a57fb2999772745d6438585f5140a7/Source/ParameterEncoding.swift
// (Alamofire is MIT-licensed)

/// Appends a dictionary of query parameters to a URL, properly percent-encoding the parameters, according to RFC 3986.
/// - parameter url: The URL to append `parameters` to. Any existing percent-encoding in the original URL will be preserved.
/// - parameter parameters: A dictionary of parameters to encode and append to the `query` of `url`
/// - note: Since there is no published specification for how to encode
///   collection types, this function follows the convention of appending `[]` to the key for array values (`foo[]=1&foo[]=2`),
///   and appending the key surrounded by square brackets for nested dictionary values (`foo[bar]=baz`).
internal func url(_ url: URL, appendingPercentEncodingOf parameters: [String: Any]) -> URL {
    guard var comp = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty else {
        return url
    }

    let existingQuery = comp.percentEncodedQuery.map { $0 + "&" } ?? ""
    comp.percentEncodedQuery = "\(existingQuery)\(query(parameters))"

    return comp.url!
}

/// Creates percent-escaped, URL encoded query string components from the given key-value pair using recursion.
///
/// - parameter key:   The key of the query component.
/// - parameter value: The value of the query component.
///
/// - returns: The percent-escaped, URL encoded query string components.
private func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
    var components: [(String, String)] = []

    if let dictionary = value as? [String: Any] {
        for (nestedKey, value) in dictionary {
            components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
        }
    } else if let array = value as? [Any] {
        for value in array {
            components += queryComponents(fromKey: "\(key)[]", value: value)
        }
    } else if let value = value as? NSNumber {
        if isBoolean(number: value) {
            components.append((escape(key), escape((value.boolValue ? "1" : "0"))))
        } else {
            components.append((escape(key), escape("\(value)")))
        }
    } else if let bool = value as? Bool {
        components.append((escape(key), escape((bool ? "1" : "0"))))
    } else {
        components.append((escape(key), escape("\(value)")))
    }

    return components
}

/// Returns a percent-escaped string following RFC 3986 for a query string key or value.
///
/// RFC 3986 states that the following characters are "reserved" characters.
///
/// - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
/// - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
///
/// In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
/// query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
/// should be percent-escaped in the query string.
///
/// - parameter string: The string to be percent-escaped.
///
/// - returns: The percent-escaped string.
private func escape(_ string: String) -> String {
    let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
    let subDelimitersToEncode = "!$&'()*+,;="

    var allowedCharacterSet = CharacterSet.urlQueryAllowed
    allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")

    var escaped = ""

    //==========================================================================================================
    //
    //  Batching is required for escaping due to an internal bug in iOS 8.1 and 8.2. Encoding more than a few
    //  hundred Chinese characters causes various malloc error crashes. To avoid this issue until iOS 8 is no
    //  longer supported, batching MUST be used for encoding. This introduces roughly a 20% overhead. For more
    //  info, please refer to:
    //
    //      - https://github.com/Alamofire/Alamofire/issues/206
    //
    //==========================================================================================================

    if #available(iOS 8.3, *) {
        escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
    } else {
        let batchSize = 50
        var index = string.startIndex

        while index != string.endIndex {
            let startIndex = index
            let endIndex = string.index(index, offsetBy: batchSize, limitedBy: string.endIndex) ?? string.endIndex
            let range = startIndex..<endIndex

            let substring = string.substring(with: range)

            escaped += substring.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? substring

            index = endIndex
        }
    }

    return escaped
}

private func query(_ parameters: [String: Any]) -> String {
    var components: [(String, String)] = []

    for key in parameters.keys.sorted(by: <) {
        let value = parameters[key]!
        components += queryComponents(fromKey: key, value: value)
    }
    return components.map { "\($0)=\($1)" }.joined(separator: "&")
}

/// Checks that the underling type of a given NSNumber is a Bool
private func isBoolean(number: NSNumber) -> Bool {
    return CFBooleanGetTypeID() == CFGetTypeID(number)
}
