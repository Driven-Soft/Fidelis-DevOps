package br.com.fiap.fidelis_api.repository;

import br.com.fiap.fidelis_api.entity.Pet;

import org.springframework.data.jpa.repository.JpaRepository;

public interface PetRepository extends JpaRepository<Pet, Long> {
}