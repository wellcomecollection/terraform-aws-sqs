# coding=utf-8
#
# This file is derived from Hypothesis, which may be found at
# https://github.com/HypothesisWorks/hypothesis
#
# Specifically, it is a modified version of code in the tooling directory:
# https://github.com/HypothesisWorks/hypothesis/blob/54966e04d972800db558d76b076f9119e05e977d/tooling/src/hypothesistooling
#
# Most of this work is copyright (C) 2013-2017 David R. MacIver
# (david@drmaciver.com), but it contains contributions by others. See
# CONTRIBUTING.rst for a full list of people who may hold copyright, and
# consult the git log if you need to determine who owns an individual
# contribution.
#
# This Source Code Form is subject to the terms of the Mozilla Public License,
# v. 2.0. If a copy of the MPL was not distributed with this file, You can
# obtain one at http://mozilla.org/MPL/2.0/.
#
# END HEADER

from __future__ import division, print_function, absolute_import

import os
import re
import sys
import subprocess
from datetime import datetime, timedelta


def current_branch():
    return (
        subprocess.check_output(["git", "rev-parse", "--abbrev-ref", "HEAD"])
        .decode("ascii")
        .strip()
    )


def tags():
    result = [
        t.decode("ascii") for t in subprocess.check_output(["git", "tag"]).split(b"\n")
    ]
    assert len(set(result)) == len(result)

    return set(result)


ROOT = (
    subprocess.check_output(["git", "rev-parse", "--show-toplevel"])
    .decode("ascii")
    .strip()
)


__version__ = None
__version_info__ = None

VERSION_FILE = os.path.join(ROOT, "version.txt")

__version__ = open(VERSION_FILE).read().strip()
__version_info__ = [int(i) for i in __version__.lstrip("v").split(".")]

assert __version__ is not None
assert __version_info__ is not None


def latest_version():
    versions = []

    for t in tags():
        # All versions get tags but not all tags are versions (and there are
        # a large number of historic tags with a different format for versions)
        # so we parse each tag as a triple of ints (MAJOR, MINOR, PATCH)
        # and skip any tag that doesn't match that.
        assert t == t.strip()
        parts = t.split(".")
        if len(parts) != 3:
            continue
        parts[0] = parts[0].lstrip("v")
        try:
            v = tuple(map(int, parts))
        except ValueError:
            continue

        versions.append((v, t))

    _, latest = max(versions)

    assert latest in tags()
    return latest


def hash_for_name(name):
    return subprocess.check_output(["git", "rev-parse", name]).decode("ascii").strip()


def is_ancestor(a, b):
    check = subprocess.call(["git", "merge-base", "--is-ancestor", a, b])
    assert 0 <= check <= 1
    return check == 0


CHANGELOG_FILE = os.path.join(ROOT, "CHANGELOG.md")


def changelog():
    with open(CHANGELOG_FILE) as i:
        return i.read()


def has_source_changes(version=None):
    if version is None:
        version = latest_version()

    tf_files = [f for f in modified_files() if f.strip().endswith(".tf")]
    return len(tf_files) != 0


def git(*args):
    subprocess.check_call(("git",) + args)


def create_tag_and_push():
    assert __version__ not in tags()
    git("config", "user.name", "Travis CI on behalf of Wellcome")
    git("config", "user.email", "wellcomedigitalplatform@wellcome.ac.uk")
    git("config", "core.sshCommand", "ssh -i deploy_key")
    git(
        "remote",
        "add",
        "ssh-origin",
        "git@github.com:wellcometrust/terraform-modules.git",
    )
    git("tag", __version__)

    subprocess.check_call(["git", "push", "ssh-origin", "HEAD:master"])
    subprocess.check_call(["git", "push", "ssh-origin", "--tags"])


def modified_files():
    files = set()
    for command in [
        ["git", "diff", "--name-only", "--diff-filter=d", latest_version(), "HEAD"],
        ["git", "diff", "--name-only"],
    ]:
        diff_output = subprocess.check_output(command).decode("ascii")
        for l in diff_output.split("\n"):
            filepath = l.strip()
            if filepath:
                assert os.path.exists(filepath)
                files.add(filepath)
    return files


RELEASE_FILE = os.path.join(ROOT, "RELEASE.md")


def has_release():
    return os.path.exists(RELEASE_FILE)


CHANGELOG_HEADER = re.compile(r"^## v\d+\.\d+\.\d+ - \d\d\d\d-\d\d-\d\d$")
RELEASE_TYPE = re.compile(r"^RELEASE_TYPE: +(major|minor|patch)")


MAJOR = "major"
MINOR = "minor"
PATCH = "patch"

VALID_RELEASE_TYPES = (MAJOR, MINOR, PATCH)


def parse_release_file():
    with open(RELEASE_FILE) as i:
        release_contents = i.read()

    release_lines = release_contents.split("\n")

    m = RELEASE_TYPE.match(release_lines[0])
    if m is not None:
        release_type = m.group(1)
        if release_type not in VALID_RELEASE_TYPES:
            print("Unrecognised release type %r" % (release_type,))
            sys.exit(1)
        del release_lines[0]
        release_contents = "\n".join(release_lines).strip()
    else:
        print(
            "RELEASE.md does not start by specifying release type. The first "
            "line of the file should be RELEASE_TYPE: followed by one of "
            "major, minor, or patch, to specify the type of release that "
            "this is (i.e. which version number to increment). Instead the "
            "first line was %r" % (release_lines[0],)
        )
        sys.exit(1)

    return release_type, release_contents


def update_changelog_and_version():
    global __version_info__
    global __version__

    with open(CHANGELOG_FILE) as i:
        contents = i.read()
    assert "\r" not in contents
    lines = contents.split("\n")
    assert contents == "\n".join(lines)
    for i, l in enumerate(lines):
        if CHANGELOG_HEADER.match(l):
            beginning = "\n".join(lines[:i])
            rest = "\n".join(lines[i:])
            assert "\n".join((beginning, rest)) == contents
            break

    release_type, release_contents = parse_release_file()

    new_version = list(__version_info__)
    bump = VALID_RELEASE_TYPES.index(release_type)
    new_version[bump] += 1
    for i in range(bump + 1, len(new_version)):
        new_version[i] = 0
    new_version = tuple(new_version)
    new_version_string = "v" + ".".join(map(str, new_version))

    __version__ = new_version_string

    open(VERSION_FILE, "w").write(new_version_string)

    now = datetime.utcnow()

    date = max([d.strftime("%Y-%m-%d") for d in (now, now + timedelta(hours=1))])

    heading_for_new_version = "## " + " - ".join((new_version_string, date))

    new_changelog_parts = [
        beginning.strip(),
        "",
        heading_for_new_version,
        "",
        release_contents,
        "",
        rest,
    ]

    with open(CHANGELOG_FILE, "w") as o:
        o.write("\n".join(new_changelog_parts))


def update_for_pending_release():
    git("config", "user.name", "Travis CI on behalf of Wellcome")
    git("config", "user.email", "wellcomedigitalplatform@wellcome.ac.uk")
    update_changelog_and_version()

    git("rm", RELEASE_FILE)
    git("add", CHANGELOG_FILE, VERSION_FILE)

    git("commit", "-m", "Bump version to %s and update changelog" % (__version__,))


def changed_files(*args):
    """
    Returns a set of changed files in a given commit range.

    :param commit_range: Arguments to pass to ``git diff``.
    """
    files = set()
    command = ["git", "diff", "--name-only"] + list(args)
    diff_output = subprocess.check_output(command).decode("ascii")
    for line in diff_output.splitlines():
        filepath = line.strip()
        if filepath:
            files.add(filepath)
    return files


def make(task, dry_run=False):
    if dry_run:
        command = ["make", "--dry-run", task]
    else:
        command = ["make", task]
    print("*** Running %r" % command, flush=True)
    subprocess.check_call(command)


def autoformat():
    subprocess.check_call(
        [
            "docker",
            "run",
            "--rm",
            "--tty",
            "--volume",
            "%s:/repo" % os.curdir,
            "--workdir",
            "/repo",
            "hashicorp/terraform",
            "fmt",
        ]
    )

    # https://graysonkoonce.com/getting-the-current-branch-name-during-a-pull-request-in-travis-ci/
    if os.environ["TRAVIS_PULL_REQUEST"] == "false":
        branch = os.environ["TRAVIS_BRANCH"]
    else:
        branch = os.environ["TRAVIS_PULL_REQUEST_BRANCH"]

    if changed_files():
        print("*** There were changes from formatting, creating a commit", flush=True)

        git("config", "user.name", "Travis CI on behalf of Wellcome")
        git("config", "user.email", "wellcomedigitalplatform@wellcome.ac.uk")
        git("config", "core.sshCommand", "ssh -i deploy_key")

        git("remote", "add", "ssh-origin", REPO_URL)

        # Unencrypt the SSH key.
        subprocess.check_call(
            [
                "openssl",
                "aes-256-cbc",
                "-K",
                os.environ["encrypted_83630750896a_key"],
                "-iv",
                os.environ["encrypted_83630750896a_iv"],
                "-in",
                "deploy_key.enc",
                "-out",
                "deploy_key",
                "-d",
            ]
        )
        subprocess.check_call(["chmod", "400", "deploy_key"])

        # We checkout the branch before we add the commit, so we don't
        # include the merge commit that Travis makes.
        git("fetch", "ssh-origin")
        git("checkout", branch)

        git("add", "--verbose", "--all")
        git("commit", "-m", "Apply auto-formatting rules")
        git("push", "ssh-origin", "HEAD:%s" % branch)
    else:
        print("*** There were no changes from auto-formatting", flush=True)


def check_release_file():
    if has_source_changes():
        if not has_release():
            print(
                "There are source changes but no RELEASE.md. Please create "
                "one to describe your changes."
            )
            sys.exit(1)
        parse_release_file()


def release():
    last_release = latest_version()

    print(
        "Current version: %s. Latest released version: %s" % (__version__, last_release)
    )

    HEAD = tools.hash_for_name("HEAD")
    MASTER = tools.hash_for_name("origin/master")
    print("Current head:", HEAD)
    print("Current master:", MASTER)

    on_master = is_ancestor(HEAD, MASTER)
    has_release = has_release()

    if has_release:
        print("Updating changelog and version")
        tools.update_for_pending_release()

    if not on_master:
        print("Not deploying due to not being on master")
        sys.exit(0)

    if not has_release:
        print("Not deploying due to no release")
        sys.exit(0)

    if os.environ.get("TRAVIS_SECURE_ENV_VARS", None) != "true":
        print("But we don't have the keys to do it")
        sys.exit(1)

    print("Decrypting secrets")

    # Unencrypt the SSH key.
    subprocess.check_call(
        [
            "openssl",
            "aes-256-cbc",
            "-K",
            os.environ["encrypted_83630750896a_key"],
            "-iv",
            os.environ["encrypted_83630750896a_iv"],
            "-in",
            "id_rsa.enc",
            "-out",
            "id_rsa",
            "-d",
        ]
    )
    subprocess.check_call(["chmod", "400", "id_rsa"])

    print("Release seems good. Pushing to GitHub now.")

    create_tag_and_push()


if __name__ == "__main__":
    try:
        command = sys.argv[1]
    except IndexError:
        sys.exit("Usage: %s <COMMAND>" % __file__)

    if command == "autoformat":
        autoformat()
    elif command == "check_release_file":
        check_release_file()
    elif command == "release":
        release()
    else:
        sys.exit("Unrecognised command: %s" % command)