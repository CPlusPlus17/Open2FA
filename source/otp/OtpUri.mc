import Toybox.Lang;
import Toybox.Test;

(:glance)
module OtpUri {
  class ParsedOtp {
    var name as String = "";
    var secret as String = "";
    var algo as Number = 0; // 0 = SHA-1, 1 = SHA-256
    var digits as Number = 6;
    var timeStep as Number = 30;
  }

  function isOtpAuthUri(str as String?) as Boolean {
    if (str == null || str.length() < 10) {
      return false;
    }
    var lower = str.toLower();
    return lower.find("otpauth://") == 0;
  }

  function parse(uri as String) as ParsedOtp? {
    if (!isOtpAuthUri(uri)) {
      return null;
    }

    var result = new ParsedOtp();

    var qIndex = uri.find("?");
    var labelPart = "";
    var queryPart = "";

    if (qIndex != null) {
      queryPart = uri.substring(qIndex + 1, uri.length());
      labelPart = uri.substring(0, qIndex);
    } else {
      labelPart = uri;
    }

    // Extract label from otpauth://totp/LABEL or otpauth://hotp/LABEL
    var totpIndex = labelPart.toLower().find("totp/");
    if (totpIndex != null) {
      labelPart = labelPart.substring(totpIndex + 5, labelPart.length());
    } else {
      var hotpIndex = labelPart.toLower().find("hotp/");
      if (hotpIndex != null) {
        labelPart = labelPart.substring(hotpIndex + 5, labelPart.length());
      } else {
        var slash = labelPart.find("//");
        if (slash != null) {
          labelPart = labelPart.substring(slash + 2, labelPart.length());
        }
      }
    }

    labelPart = urlDecode(labelPart);
    if (labelPart != null && labelPart.length() > 0) {
      result.name = labelPart;
    }

    if (queryPart.length() > 0) {
      var params = splitString(queryPart, '&');
      for (var i = 0; i < params.size(); i++) {
        var p = params[i] as String;
        var eqIndex = p.find("=");
        if (eqIndex != null) {
          var key = p.substring(0, eqIndex).toLower();
          var val = p.substring(eqIndex + 1, p.length());
          val = urlDecode(val);

          if (key.equals("secret")) {
            result.secret = val;
          } else if (key.equals("issuer")) {
            if (result.name.length() == 0) {
              result.name = val;
            } else if (result.name.find(val) == null) {
              result.name = val + ": " + result.name;
            }
          } else if (key.equals("algorithm")) {
            var a = val.toUpper();
            if (a.equals("SHA256")) {
              result.algo = 1;
            } else if (a.equals("SHA1")) {
              result.algo = 0;
            }
          } else if (key.equals("digits")) {
            var d = val.toNumber();
            if (d != null && d >= 6 && d <= 8) {
              result.digits = d;
            }
          } else if (key.equals("period")) {
            var step = val.toNumber();
            if (step != null && step > 0) {
              result.timeStep = step;
            }
          }
        }
      }
    }

    return result;
  }

  function splitString(str as String, delim as Char) as Array<String> {
    var res = [] as Array<String>;
    var start = 0;
    var len = str.length();
    for (var i = 0; i < len; i++) {
      if (str.toCharArray()[i] == delim) {
        if (i > start) {
          res.add(str.substring(start, i));
        }
        start = i + 1;
      }
    }
    if (start < len) {
      res.add(str.substring(start, len));
    }
    return res;
  }

  function urlDecode(s as String) as String {
    var out = "";
    var i = 0;
    var len = s.length();
    while (i < len) {
      var c = s.toCharArray()[i];
      if (c == '%' && i + 2 < len) {
        var hex = s.substring(i + 1, i + 3).toUpper();
        if (hex.equals("20")) {
          out += " ";
          i += 3;
          continue;
        } else if (hex.equals("3A")) {
          out += ":";
          i += 3;
          continue;
        } else if (hex.equals("40")) {
          out += "@";
          i += 3;
          continue;
        } else if (hex.equals("2F")) {
          out += "/";
          i += 3;
          continue;
        }
      } else if (c == '+') {
        out += " ";
        i++;
        continue;
      }
      out += s.substring(i, i + 1);
      i++;
    }
    return out;
  }

  (:test)
  function testParseOtpUri(logger as Test.Logger) as Boolean {
    var uri = "otpauth://totp/Google:alice@gmail.com?secret=JBSWY3DPEHPK3PXP&issuer=Google&digits=6&period=30";
    var parsed = parse(uri);
    if (parsed == null) {
      logger.debug("Failed to parse URI");
      return false;
    }
    if (!parsed.secret.equals("JBSWY3DPEHPK3PXP")) {
      logger.debug("Secret mismatch: " + parsed.secret);
      return false;
    }
    if (parsed.digits != 6 || parsed.timeStep != 30 || parsed.algo != 0) {
      logger.debug("Parameters mismatch");
      return false;
    }
    return true;
  }

  (:test)
  function testParseOtpUriSha256(logger as Test.Logger) as Boolean {
    var uri = "otpauth://totp/GitHub%3Aoctocat?secret=KRUGS4ZANFZSAYJA&digits=8&period=60&algorithm=SHA256";
    var parsed = parse(uri);
    if (parsed == null) {
      logger.debug("Failed to parse URI");
      return false;
    }
    if (!parsed.secret.equals("KRUGS4ZANFZSAYJA")) {
      logger.debug("Secret mismatch: " + parsed.secret);
      return false;
    }
    if (parsed.digits != 8 || parsed.timeStep != 60 || parsed.algo != 1) {
      logger.debug("Parameters mismatch");
      return false;
    }
    if (!parsed.name.equals("GitHub:octocat")) {
      logger.debug("Name mismatch: " + parsed.name);
      return false;
    }
    return true;
  }
}
