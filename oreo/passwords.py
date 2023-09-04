import secrets

from base64 import urlsafe_b64encode as b64e, urlsafe_b64decode as b64d
from cryptography.fernet import Fernet
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC

# Adapted From:
# Answer: https://stackoverflow.com/a/55147077/10827766
# User: https://stackoverflow.com/users/100297/martijn-pieters

backend = default_backend()
iterations = 100000
encoding = "utf-8"


def derive_key(password, salt, iterations=iterations):
    """Derive a secret key from a given password and salt"""
    return b64e(
        PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=32,
            salt=salt,
            iterations=iterations,
            backend=backend,
        ).derive(password)
    )


def _password_encrypt(
    func,
    password,
    iterations=iterations,
    salt=secrets.token_bytes(16),
    encoding=encoding,
):
    decryption = b64d(
        func(Fernet(derive_key(password.encode(encoding), salt, iterations)))
    )
    return b64e(b"%b%b%b" % (salt, iterations.to_bytes(4, "big"), decryption))


# Adapted From: https://github.com/pyca/cryptography/blob/main/src/cryptography/fernet.py#L54
# And: https://github.com/pyca/cryptography/blob/main/src/cryptography/fernet.py#L58
# And:
# Answer: https://stackoverflow.com/a/73599705
# User: https://stackoverflow.com/users/9910846/cheesus
def password_encrypt_parts(
    message, *args, iv=secrets.token_bytes(16), encoding=encoding, **kwargs
):
    return _password_encrypt(
        lambda f: f._encrypt_from_parts(message.encode(encoding), 0, iv),
        *args,
        encoding=encoding,
        **kwargs,
    )


def password_encrypt(message, *args, encoding=encoding, **kwargs):
    return _password_encrypt(
        lambda f: f.encrypt(message.encode(encoding)),
        *args,
        encoding=encoding,
        **kwargs,
    )


def password_decrypt(token, password, encoding=encoding):
    decodes = b64d(token)
    return (
        Fernet(
            derive_key(
                password.encode(encoding),
                decodes[0:16],
                int.from_bytes(decodes[16:20], "big"),
            )
        )
        .decrypt(b64e(decodes[20:]))
        .decode(encoding)
    )
