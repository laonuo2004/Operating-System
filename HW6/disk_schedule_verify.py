from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Dict, List, Tuple

REQUEST_QUEUE = [86, 147, 91, 177, 94, 150, 102, 175, 130]
TRACK_MIN = 0
TRACK_MAX = 199
CURRENT_TRACK = 143
PREVIOUS_TRACK = 125


@dataclass
class ScheduleResult:
    name: str
    path: List[int]
    moves: List[int]
    total: int


def compute_moves(path: List[int]) -> Tuple[List[int], int]:
    deltas = [abs(path[i + 1] - path[i]) for i in range(len(path) - 1)]
    return deltas, sum(deltas)


def fcfs(queue: List[int]) -> List[int]:
    return [CURRENT_TRACK] + queue


def sstf(queue: List[int]) -> List[int]:
    pending = queue.copy()
    path = [CURRENT_TRACK]
    position = CURRENT_TRACK

    while pending:
        next_idx = min(range(len(pending)), key=lambda i: abs(pending[i] - position))
        position = pending.pop(next_idx)
        path.append(position)

    return path


def scan(queue: List[int], direction_up: bool) -> List[int]:
    higher = sorted([t for t in queue if t >= CURRENT_TRACK])
    lower = sorted([t for t in queue if t < CURRENT_TRACK])
    path = [CURRENT_TRACK]

    if direction_up:
        path.extend(higher)
        if path[-1] != TRACK_MAX:
            path.append(TRACK_MAX)
        path.extend(reversed(lower))
    else:
        path.extend(reversed(lower))
        if path[-1] != TRACK_MIN:
            path.append(TRACK_MIN)
        path.extend(higher)

    return path


def look(queue: List[int], direction_up: bool) -> List[int]:
    higher = sorted([t for t in queue if t >= CURRENT_TRACK])
    lower = sorted([t for t in queue if t < CURRENT_TRACK])
    path = [CURRENT_TRACK]

    if direction_up:
        path.extend(higher)
        path.extend(reversed(lower))
    else:
        path.extend(reversed(lower))
        path.extend(higher)

    return path


def cscan(queue: List[int], direction_up: bool) -> List[int]:
    higher = sorted([t for t in queue if t >= CURRENT_TRACK])
    lower = sorted([t for t in queue if t < CURRENT_TRACK])
    path = [CURRENT_TRACK]

    if direction_up:
        path.extend(higher)
        if lower:
            if path[-1] != TRACK_MAX:
                path.append(TRACK_MAX)
            path.append(TRACK_MIN)
            path.extend(lower)
    else:
        path.extend(reversed(lower))
        if higher:
            if path[-1] != TRACK_MIN:
                path.append(TRACK_MIN)
            path.append(TRACK_MAX)
            path.extend(reversed(higher))

    return path


def evaluate(name: str, builder: Callable[[], List[int]]) -> ScheduleResult:
    path = builder()
    moves, total = compute_moves(path)
    return ScheduleResult(name, path, moves, total)


def main() -> None:
    direction_up = CURRENT_TRACK > PREVIOUS_TRACK

    strategies: Dict[str, Callable[[], List[int]]] = {
        "FCFS": lambda: fcfs(REQUEST_QUEUE),
        "SSTF": lambda: sstf(REQUEST_QUEUE),
        "SCAN": lambda: scan(REQUEST_QUEUE, direction_up),
        "LOOK": lambda: look(REQUEST_QUEUE, direction_up),
        "C-SCAN": lambda: cscan(REQUEST_QUEUE, direction_up),
    }

    for name, builder in strategies.items():
        result = evaluate(name, builder)
        print(f"{result.name}:")
        print(f"  处理顺序: {result.path}")
        print(f"  每次移动: {result.moves}")
        print(f"  总移动量: {result.total}\n")


if __name__ == "__main__":
    main()

