| True \ Pred    | RC Plane | Bird | Drone | Drone + Bird | Total True |
| -------------- | -------- | ---- | ----- | ------------ | ---------- |
| RC Plane       | 586      | 0    | 2     | 5            | 593        |
| Bird           | 0        | 507  | 0     | 86           | 593        |
| Drone          | 2        | 0    | 618   | 2            | 622        |
| Drone+Bird     | 5        | 88   | 7     | 505          | 605        |
| **Total Pred** | 593      | 595  | 627   | 598          | **2413**   |


## Accuracy =(586+507+618+505)/2413 ≈ 91.85%


# per class
## RC Plane:

Precision = 586 / (586 + 0 + 2 + 5) = 586 / 593 ≈ 0.988

Recall = 586 / 593 ≈ 0.988

F1 Score = 2 × (0.988 × 0.988) / (0.988 + 0.988) ≈ 0.988

## Bird:

Precision = 507 / (0 + 507 + 0 + 88) = 507 / 595 ≈ 0.852

Recall = 507 / 593 ≈ 0.855

F1 Score ≈ 0.854

## Drone:
Precision = 618 / (2 + 0 + 618 + 7) = 618 / 627 ≈ 0.986

Recall = 618 / 622 ≈ 0.994

F1 Score ≈ 0.990

## Drone + Bird:
Precision = 505 / (5 + 86 + 2 + 505) = 505 / 598 ≈ 0.844

Recall = 505 / 605 ≈ 0.835

F1 Score ≈ 0.839

# Macro-Averaged Scores
Macro Precision ≈ (0.988 + 0.852 + 0.986 + 0.844) / 4 ≈ 0.917

Macro Recall ≈ (0.988 + 0.855 + 0.994 + 0.835) / 4 ≈ 0.918

Macro F1 Score ≈ (0.988 + 0.854 + 0.990 + 0.839) / 4 ≈ 0.918
