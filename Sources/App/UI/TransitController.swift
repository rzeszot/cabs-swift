import Foundation
import Fluent
import Vapor

struct TransitController: RouteCollection {
    let transitService: TransitService

    func boot(routes: RoutesBuilder) throws {
        routes.group("transits") { transits in
            transits.get(use: listAllTransitsa)
            transits.post(use: createTransit)
            
            transits.group(":transit_id") { transit in
                transit.get(use: getTransit)
            }
        }
        
    }
    
    // MARK: -
    
    func listAllTransitsa(request: Request) async throws -> [TransitResponseDTO] {
        let transits = try await transitService.listAll()
        return transits.map(TransitResponseDTO.init(transit:))
    }
    
    func getTransit(request: Request) async throws -> TransitResponseDTO {
        guard let transitId = request.parameters.get(":transit_id", as: UUID.self) else { throw Abort(.badRequest) }

        let transit = try await transitService.findDriversForTransit(transitId: transitId)
        return TransitResponseDTO(transit: transit)
    }
    
    func createTransit(request: Request) async throws -> TransitResponseDTO {
        let dto = try request.content.decode(TransitCreateRequestDTO.self)
        let transit = try await transitService.createTransit(
            clientId: dto.clientId,
            from: dto.from.toAddress(),
            to: dto.to.toAddress(),
            carClass: dto.carClass
        )
        
        return TransitResponseDTO(transit: transit)
    }
      
}





//
//    #[Route('/transits', methods: ['POST'])]
//    public function createTransit(TransitDTO $transitDTO): Response
//    {
//        $transit = $this->transitService->createTransit($transitDTO);
//        return new JsonResponse($this->transitService->loadTransit($transit->getId()));
//    }
//
//    #[Route('/transits/{id}/changeAddressTo', methods: ['POST'])]
//    public function changeAddressTo(int $id, AddressDTO $addressDTO): Response
//    {
//        $this->transitService->changeTransitAddressTo($id, $addressDTO);
//        return new JsonResponse($this->transitService->loadTransit($id));
//    }
//
//    #[Route('/transits/{id}/changeAddressFrom', methods: ['POST'])]
//    public function changeAddressFrom(int $id, AddressDTO $addressDTO): Response
//    {
//        $this->transitService->changeTransitAddressFrom($id, $addressDTO);
//        return new JsonResponse($this->transitService->loadTransit($id));
//    }
//
//    #[Route('/transits/{id}/cancel', methods: ['POST'])]
//    public function cancel(int $id): Response
//    {
//        $this->transitService->cancelTransit($id);
//        return new JsonResponse($this->transitService->loadTransit($id));
//    }
//
//    #[Route('/transits/{id}/publish', methods: ['POST'])]
//    public function publishTransit(int $id): Response
//    {
//        $this->transitService->publishTransit($id);
//        return new JsonResponse($this->transitService->loadTransit($id));
//    }
//
//    #[Route('/transits/{id}/findDrivers', methods: ['POST'])]
//    public function findDriversForTransit(int $id): Response
//    {
//        $this->transitService->findDriversForTransit($id);
//        return new JsonResponse($this->transitService->loadTransit($id));
//    }
//
//    #[Route('/transits/{id}/accept/{driverId}', methods: ['POST'])]
//    public function acceptTransit(int $id, int $driverId): Response
//    {
//        $this->transitService->acceptTransit($driverId, $id);
//        return new JsonResponse($this->transitService->loadTransit($id));
//    }
//
//    #[Route('/transits/{id}/start/{driverId}', methods: ['POST'])]
//    public function start(int $id, int $driverId): Response
//    {
//        $this->transitService->startTransit($driverId, $id);
//        return new JsonResponse($this->transitService->loadTransit($id));
//    }
//
//    #[Route('/transits/{id}/reject/{driverId}', methods: ['POST'])]
//    public function reject(int $id, int $driverId): Response
//    {
//        $this->transitService->rejectTransit($driverId, $id);
//        return new JsonResponse($this->transitService->loadTransit($id));
//    }
//
//    #[Route('/transits/{id}/complete/{driverId}', methods: ['POST'])]
//    public function complete(int $id, int $driverId, AddressDTO $destination): Response
//    {
//        $this->transitService->completeTransit($driverId, $id, $destination);
//        return new JsonResponse($this->transitService->loadTransit($id));
//    }
//}
