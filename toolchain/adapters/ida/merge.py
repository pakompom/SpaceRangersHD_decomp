"""Three-way decisions shared by the CLI's IDA worker and unit tests."""


def decision(current, desired, previous=None, replaceable=False):
    if current == desired:
        return "unchanged"
    if desired is None:
        return "remove" if previous is not None and current == previous["actual"] else "conflict"
    if previous is not None:
        return "update" if current == previous["actual"] else "conflict"
    if current is None or replaceable:
        return "create" if current is None else "update"
    return "conflict"
