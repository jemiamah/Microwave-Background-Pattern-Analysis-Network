;; CMB Data Management Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-parameters (err u101))

;; Data Variables
(define-data-var dataset-counter uint u0)
(define-map datasets uint {
    name: (string-ascii 100),
    description: (string-utf8 500),
    data-hash: (buff 32),
    size: uint,
    upload-block: uint,
    uploader: principal
})

;; Public Functions
(define-public (upload-dataset (name (string-ascii 100)) (description (string-utf8 500)) (data-hash (buff 32)) (size uint))
    (let
        (
            (dataset-id (+ (var-get dataset-counter) u1))
        )
        (asserts! (> size u0) err-invalid-parameters)
        (map-set datasets dataset-id {
            name: name,
            description: description,
            data-hash: data-hash,
            size: size,
            upload-block: block-height,
            uploader: tx-sender
        })
        (var-set dataset-counter dataset-id)
        (ok dataset-id)
    )
)

(define-public (update-dataset-description (dataset-id uint) (new-description (string-utf8 500)))
    (let
        (
            (dataset (unwrap! (map-get? datasets dataset-id) err-invalid-parameters))
        )
        (asserts! (is-eq tx-sender (get uploader dataset)) err-owner-only)
        (map-set datasets dataset-id
            (merge dataset {
                description: new-description
            })
        )
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-dataset (dataset-id uint))
    (map-get? datasets dataset-id)
)

(define-read-only (get-dataset-count)
    (var-get dataset-counter)
)

