package br.com.fiap.fidelis_api.controller;

import br.com.fiap.fidelis_api.entity.Pet;
import br.com.fiap.fidelis_api.repository.PetRepository;

import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/pets")
public class PetController {

    private final PetRepository repository;

    public PetController(PetRepository repository) {
        this.repository = repository;
    }

    // GET ALL
    @GetMapping
    public List<Pet> listarPets() {
        return repository.findAll();
    }

    // GET BY ID
    @GetMapping("/{id}")
    public Optional<Pet> buscarPorId(@PathVariable Long id) {
        return repository.findById(id);
    }

    // POST
    @PostMapping
    public Pet cadastrarPet(@RequestBody Pet pet) {
        return repository.save(pet);
    }

    // PUT
    @PutMapping("/{id}")
    public Pet atualizarPet(@PathVariable Long id,
                            @RequestBody Pet petAtualizado) {

        Pet pet = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Pet não encontrado"));

        pet.setNome(petAtualizado.getNome());
        pet.setEspecie(petAtualizado.getEspecie());
        pet.setIdade(petAtualizado.getIdade());

        return repository.save(pet);
    }

    // DELETE
    @DeleteMapping("/{id}")
    public void deletarPet(@PathVariable Long id) {
        repository.deleteById(id);
    }
}