;; Pattern Discovery Claims Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-parameters (err u101))

;; Data Variables
(define-data-var claim-counter uint u0)
(define-map claims uint {
    title: (string-ascii 100),
    description: (string-utf8 1000),
    claimer: principal,
    evidence-hash: (buff 32),
    status: (string-ascii 20),
    claim-block: uint
})

;; Public Functions
(define-public (submit-claim (title (string-ascii 100)) (description (string-utf8 1000)) (evidence-hash (buff 32)))
    (let
        (
            (claim-id (+ (var-get claim-counter) u1))
        )
        (map-set claims claim-id {
            title: title,
            description: description,
            claimer: tx-sender,
            evidence-hash: evidence-hash,
            status: "submitted",
            claim-block: block-height
        })
        (var-set claim-counter claim-id)
        (ok claim-id)
    )
)

(define-public (update-claim-status (claim-id uint) (new-status (string-ascii 20)))
    (let
        (
            (claim (unwrap! (map-get? claims claim-id) err-invalid-parameters))
        )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-set claims claim-id
            (merge claim {
                status: new-status
            })
        )
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-claim (claim-id uint))
    (map-get? claims claim-id)
)

(define-read-only (get-claim-count)
    (var-get claim-counter)
)

