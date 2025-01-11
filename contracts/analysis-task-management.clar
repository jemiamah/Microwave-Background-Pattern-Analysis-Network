;; Analysis Task Management Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-parameters (err u101))
(define-constant err-task-not-open (err u102))

;; Data Variables
(define-data-var task-counter uint u0)
(define-map tasks uint {
    description: (string-utf8 500),
    reward: uint,
    status: (string-ascii 20),
    creator: principal,
    assigned-to: (optional principal),
    result-hash: (optional (buff 32))
})

;; Public Functions
(define-public (create-task (description (string-utf8 500)) (reward uint))
    (let
        (
            (task-id (+ (var-get task-counter) u1))
        )
        (asserts! (> reward u0) err-invalid-parameters)
        (map-set tasks task-id {
            description: description,
            reward: reward,
            status: "open",
            creator: tx-sender,
            assigned-to: none,
            result-hash: none
        })
        (var-set task-counter task-id)
        (ok task-id)
    )
)

(define-public (assign-task (task-id uint))
    (let
        (
            (task (unwrap! (map-get? tasks task-id) err-invalid-parameters))
        )
        (asserts! (is-eq (get status task) "open") err-task-not-open)
        (map-set tasks task-id
            (merge task {
                status: "assigned",
                assigned-to: (some tx-sender)
            })
        )
        (ok true)
    )
)

(define-public (submit-result (task-id uint) (result-hash (buff 32)))
    (let
        (
            (task (unwrap! (map-get? tasks task-id) err-invalid-parameters))
        )
        (asserts! (is-eq (some tx-sender) (get assigned-to task)) err-owner-only)
        (asserts! (is-eq (get status task) "assigned") err-task-not-open)
        (map-set tasks task-id
            (merge task {
                status: "completed",
                result-hash: (some result-hash)
            })
        )
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-task (task-id uint))
    (map-get? tasks task-id)
)

(define-read-only (get-task-count)
    (var-get task-counter)
)

