import Toybox.Lang;
import Toybox.Application;

import Otp;
import Base32;
import OtpUri;

(:glance)
class OtpCode {
  private var otp;
  private var name as String;

  function initialize(code, codeName as String) {
    otp = code;
    name = codeName;
  }

  function getOtp() {
    return otp;
  }

  function getName() as String {
    return name;
  }
}

(:glance)
const MAX_CODES = 15;
(:glance)
const INDEX_KEY = "lastUsedIndex";

(:glance)
class CodeStore {
  private var otps as Array<OtpCode> = [];
  private var lastUsedIndex as Numeric;

  function initialize() {
    for (var i = 1; i <= MAX_CODES; i++) {
      var code = loadOtp(i);
      if (code != null) {
        otps.add(code);
      }
    }
    lastUsedIndex = Application.Storage.getValue(INDEX_KEY);
    if (
      lastUsedIndex == null ||
      lastUsedIndex < 0 ||
      lastUsedIndex >= otps.size()
    ) {
      lastUsedIndex = 0;
    }
  }

  private function loadOtp(index) as OtpCode? {
    var enabled = Application.Properties.getValue("enabled" + index);
    var name = Application.Properties.getValue("name" + index);
    var secret = Application.Properties.getValue("code" + index);
    var algo = Application.Properties.getValue("algo" + index);
    var digits = Application.Properties.getValue("digits" + index);
    var timeStep = Application.Properties.getValue("timeStep" + index);

    if (enabled == null || !enabled || secret == null || "".equals(secret)) {
      return null;
    }

    if (name == null) {
      name = "";
    }
    if (algo == null) {
      algo = 0;
    }
    if (digits == null) {
      digits = 6;
    }
    if (timeStep == null) {
      timeStep = 30;
    }

    // Check if secret is an otpauth:// URI
    if (OtpUri.isOtpAuthUri(secret)) {
      var parsed = OtpUri.parse(secret);
      if (parsed != null) {
        secret = parsed.secret;
        if ("".equals(name)) {
          name = parsed.name;
        }
        algo = parsed.algo;
        digits = parsed.digits;
        timeStep = parsed.timeStep;
      }
    }

    if ("".equals(name)) {
      name = "Account " + index;
    }

    var otp = Otp.TotpFromBase32AlgoDigitsTimeStep(
      secret,
      algo,
      digits,
      timeStep
    );
    return new OtpCode(otp, name);
  }

  function isEmpty() as Boolean {
    return otps.size() == 0;
  }

  function size() as Number {
    return otps.size();
  }

  function saveLastUsedIndex() as Void {
    Application.Storage.setValue(INDEX_KEY, lastUsedIndex);
  }

  function selectNext() as Void {
    if (otps.size() == 0) {
      return;
    }
    var nextIndex = lastUsedIndex + 1;
    if (nextIndex >= otps.size()) {
      nextIndex = 0;
    }
    lastUsedIndex = nextIndex;
    saveLastUsedIndex();
  }

  function selectPrev() as Void {
    if (otps.size() == 0) {
      return;
    }
    var nextIndex = lastUsedIndex - 1;
    if (nextIndex < 0) {
      nextIndex = otps.size() - 1;
    }
    lastUsedIndex = nextIndex;
    saveLastUsedIndex();
  }

  function getIndex() as Numeric {
    return lastUsedIndex;
  }

  function getOtpCode() as OtpCode? {
    if (lastUsedIndex < 0 || lastUsedIndex >= otps.size()) {
      lastUsedIndex = 0;
    }
    if (otps.size() == 0) {
      return null;
    }
    return otps[lastUsedIndex];
  }
}
