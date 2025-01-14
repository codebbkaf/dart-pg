// Copyright 2022-present by Nguyen Van Nguyen <nguyennv1981@gmail.com>. All rights reserved.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code.

/// Reason for Revocation
/// See https://tools.ietf.org/html/rfc4880#section-5.2.3.23
enum RevocationReasonTag {
  /// No reason specified (key revocations or cert revocations)
  noReason(0),

  /// Key is superseded (key revocations)
  keySuperseded(1),

  /// Key material has been compromised (key revocations)
  keyCompromised(2),

  /// Key is retired and no longer used (key revocations)
  keyRetired(3),

  /// User ID information is no longer valid (cert revocations)
  userIDInvalid(32);

  final int value;

  const RevocationReasonTag(this.value);
}
