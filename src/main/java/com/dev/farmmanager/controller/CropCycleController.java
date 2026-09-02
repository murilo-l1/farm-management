package com.dev.farmmanager.controller;

import com.dev.farmmanager.controller.base.BaseController;
import com.dev.farmmanager.domain.dto.cropcycle.CropCycleDto;
import com.dev.farmmanager.domain.dto.cropcycle.CropCycleOptionDto;
import com.dev.farmmanager.domain.dto.cropcycle.CropCyclePageDto;
import com.dev.farmmanager.domain.enumeration.CropCycleStatus;
import com.dev.farmmanager.domain.payload.cropcycle.CropCyclePayload;
import com.dev.farmmanager.usecase.cropcycle.CropCycleCommand;
import com.dev.farmmanager.usecase.cropcycle.CropCycleFetch;
import io.swagger.v3.oas.annotations.Operation;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping(value = "api/farm/crop-cycle", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class CropCycleController extends BaseController {

    private final CropCycleCommand command;
    private final CropCycleFetch fetch;

    @GetMapping("/options")
    @Operation(summary = "Get crop cycle id/name pairs for dropdowns")
    public ResponseEntity<List<CropCycleOptionDto>> findOptions() {
        return fetch.findOptions();
    }

    @GetMapping
    @Operation(summary = "Find all crop cycles with summary stats")
    public ResponseEntity<CropCyclePageDto> findAll(
            @RequestParam(required = false) CropCycleStatus status,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        return fetch.findAll(status, date);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get a crop cycle by ID")
    public ResponseEntity<CropCycleDto> getById(@PathVariable Integer id) {
        return fetch.getById(id);
    }

    @PostMapping
    @Operation(summary = "Creates a new crop cycle")
    public ResponseEntity<CropCycleDto> create(@Valid @RequestBody CropCyclePayload payload) {
        return command.create(payload);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update a crop cycle by ID")
    public ResponseEntity<CropCycleDto> update(@PathVariable Integer id, @Valid @RequestBody CropCyclePayload payload) {
        return command.update(id, payload);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete a crop cycle by ID")
    public ResponseEntity<Void> delete(@PathVariable Integer id) {
        return command.delete(id);
    }

}
