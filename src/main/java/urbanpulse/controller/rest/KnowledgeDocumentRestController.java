package urbanpulse.controller.rest;

import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import urbanpulse.dto.KnowledgeDocument;
import urbanpulse.service.KnowledgeDocumentService;

import java.util.List;

@RestController
@Slf4j
@AllArgsConstructor
@Tag(name = "Knowledge Documents", description = "Versioned procedures and regulations available for consultation and RAG")
@RequestMapping("/api/v1/knowledge-documents")
public class KnowledgeDocumentRestController {
    private final KnowledgeDocumentService knowledgeDocumentService;

    /*
     * Gets indexed procedures and regulations available for consultation.
    */
    @GetMapping("/")
    public ResponseEntity<List<KnowledgeDocument>> getKnowledgeDocuments() {
        //TODO
        return null;
    }

    /*
     * Gets a knowledge document by its ID.
     * If it does not exist, it returns a 404 error.
    */
    @GetMapping("/{id}")
    public ResponseEntity<KnowledgeDocument> getKnowledgeDocumentById() {
        //TODO
        return null;
    }

    /*
     * Searches procedures and regulations to support assisted recommendations.
    */
    @GetMapping("/search")
    public ResponseEntity<List<KnowledgeDocument>> searchKnowledgeDocuments() {
        //TODO
        return null;
    }

    /*
     * Saves a versioned procedure or regulation for later indexing.
    */
    @PostMapping("/")
    public ResponseEntity<KnowledgeDocument> addKnowledgeDocument() {
        //TODO
        return null;
    }
}
