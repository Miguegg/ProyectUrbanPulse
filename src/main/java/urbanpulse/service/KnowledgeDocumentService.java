package urbanpulse.service;

import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;
import urbanpulse.dao.KnowledgeDocumentRepository;
import urbanpulse.dto.KnowledgeDocument;

@Service
@AllArgsConstructor
public class KnowledgeDocumentService {
    private final KnowledgeDocumentRepository knowledgeDocumentRepository;
}
