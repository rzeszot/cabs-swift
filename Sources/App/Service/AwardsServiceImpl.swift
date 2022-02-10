import Foundation
import Vapor

class AwardsServiceImpl: AwardsService {
    private let accountRepository: AwardsAccountRepository
    private let clientRepository: ClientRepository
    private let clock: Clock

    init(
        accountRepository: AwardsAccountRepository,
        clientRepository: ClientRepository,
        clock: Clock
    ) {
        self.accountRepository = accountRepository
        self.clientRepository = clientRepository
        self.clock = clock
    }
    func findBy(clientId: UUID) async throws -> AwardsAccountDTO {
        guard let client = try await clientRepository.findBy(id: clientId) else { throw Abort(.notFound) }
        guard let awardsAccount = try await accountRepository.findBy(client: client) else { throw Abort(.notFound) }

        return AwardsAccountDTO(awardsAccount: awardsAccount)
    }

    func registerToProgram(clientId: UUID) async throws {
        guard let _ = try await clientRepository.findBy(id: clientId) else { throw Abort(.notFound) }

        let account = AwardsAccount()
        account.$client.id = clientId
        account.isActive = false
        account.date = clock.now()

        _ = try await accountRepository.save(account)
    }

    func activateAccount(clientId: UUID) async throws {
        guard let client = try await clientRepository.findBy(id: clientId) else { throw Abort(.notFound) }
        guard let account = try await accountRepository.findBy(client: client) else { throw Abort(.notFound) }

        account.isActive = true

        _ = try await accountRepository.save(account)
    }

    func deactivateAccount(clientId: UUID) async throws {
        guard let client = try await clientRepository.findBy(id: clientId) else { throw Abort(.notFound) }
        guard let account = try await accountRepository.findBy(client: client) else { throw Abort(.notFound) }

        account.isActive = false

        _ = try await accountRepository.save(account)
    }

}

//    private AwardedMilesRepository $milesRepository;
//    private ClientRepository $clientRepository;
//    private TransitRepository $transitRepository;
//    private AppProperties $appProperties;
//
//    public function registerMiles(int $clientId, int $transitId): ?AwardedMiles
//    {
//        $account = $this->accountRepository->findByClient($this->clientRepository->getOne($clientId));
//        $transit = $this->transitRepository->getOne($transitId);
//        if($transit === null) {
//            throw new \InvalidArgumentException('Transit does not exists, id = '.$transitId);
//        }
//
//        $now = $this->clock->now();
//        if($account === null || !$account->isActive()) {
//            return null;
//        } else {
//            $miles = new AwardedMiles();
//            $miles->setTransit($transit);
//            $miles->setDate($this->clock->now());
//            $miles->setClient($account->getClient());
//            $miles->setMiles($this->appProperties->getDefaultMilesBonus());
//            $miles->setExpirationDate($now->modify(sprintf('+%s days', $this->appProperties->getMilesExpirationInDays())));
//            $miles->setSpecial(false);
//            $account->increaseTransactions();
//
//            $this->milesRepository->save($miles);
//            $this->accountRepository->save($account);
//
//            return $miles;
//        }
//    }
//
//    public function registerSpecialMiles(int $clientId, int $miles): AwardedMiles
//    {
//        $account = $this->accountRepository->findByClient($this->clientRepository->getOne($clientId));
//
//        if($account === null) {
//            throw new \InvalidArgumentException('Account does not exists, id = '.$clientId);
//        } else {
//            $_miles = new AwardedMiles();
//            $_miles->setTransit(null);
//            $_miles->setClient($account->getClient());
//            $_miles->setMiles($miles);
//            $_miles->setDate($this->clock->now());
//            $_miles->setSpecial(true);
//            $account->increaseTransactions();
//            $this->milesRepository->save($_miles);
//            $this->accountRepository->save($account);
//            return $_miles;
//        }
//    }
//
//    public function removeMiles(int $clientId, int $miles): void
//    {
//        $client = $this->clientRepository->getOne($clientId);
//        $account = $this->accountRepository->findByClient($client);
//
//        if($account===null) {
//            throw new \InvalidArgumentException('Account does not exists, id = '.$clientId);
//        } else {
//            if($this->calculateBalance($clientId) >= $miles && $account->isActive()) {
//                $milesList = $this->milesRepository->findAllByClient($client);
//                $transitsCounter = count($this->transitRepository->findByClient($client));
//                if(count($client->getClaims()) >= 3) {
//                    usort($milesList, fn(AwardedMiles $a, AwardedMiles $b) => $a->getExpirationDate() <=> $b->getExpirationDate());
//                    $milesList = array_reverse($milesList);
//                } else if($client->getType() === Client::TYPE_VIP) {
//                    usort($milesList, fn(AwardedMiles $a, AwardedMiles $b) => $a->getExpirationDate() <=> $b->getExpirationDate());
//                    usort($milesList, fn(AwardedMiles $a, AwardedMiles $b) => (int) $a->isSpecial() <=> (int) $b->isSpecial());
//                } else if($transitsCounter >= 15 && $this->isSunday()) {
//                    usort($milesList, fn(AwardedMiles $a, AwardedMiles $b) => $a->getExpirationDate() <=> $b->getExpirationDate());
//                    usort($milesList, fn(AwardedMiles $a, AwardedMiles $b) => (int) $a->isSpecial() <=> (int) $b->isSpecial());
//                } else if($transitsCounter >= 15) {
//                    usort($milesList, fn(AwardedMiles $a, AwardedMiles $b) => $a->getDate() <=> $b->getDate());
//                    usort($milesList, fn(AwardedMiles $a, AwardedMiles $b) => (int) $a->isSpecial() <=> (int) $b->isSpecial());
//                } else {
//                    usort($milesList, fn(AwardedMiles $a, AwardedMiles $b) => $a->getDate() <=> $b->getDate());
//                }
//
//                foreach ($milesList as $iter) {
//                    if($miles <= 0) {
//                        break;
//                    }
//                    if($iter->isSpecial() || $iter->getExpirationDate() > $this->clock->now()) {
//                        if($iter->getMiles() <= $miles) {
//                            $miles -= $iter->getMiles();
//                            $iter->setMiles(0);
//                        } else {
//                            $iter->setMiles($iter->getMiles() - $miles);
//                            $miles = 0;
//                        }
//                        $this->milesRepository->save($miles);
//                    }
//                }
//            } else {
//                throw new \InvalidArgumentException('Insufficient miles, id = '.$clientId.', miles requested = '.$miles);
//            }
//        }
//    }
//
//    public function calculateBalance(int $clientId): int
//    {
//        $client = $this->clientRepository->getOne($clientId);
//        $milesList = $this->milesRepository->findAllByClient($client);
//
//        return array_sum(
//            array_map(
//                fn(AwardedMiles $miles) => $miles->getMiles(),
//                array_filter(
//                    $milesList,
//                    fn(AwardedMiles $miles) => $miles->getExpirationDate() !== null && $miles->getExpirationDate() > $this->clock->now() || $miles->isSpecial())
//            )
//        );
//    }
//
//    public function transferMiles(int $fromClientId, int $toClientId, int $miles): void
//    {
//        $fromClient = $this->clientRepository->getOne($fromClientId);
//        $accountFrom = $this->accountRepository->findByClient($fromClient);
//        $accountTo = $this->accountRepository->findByClient($this->clientRepository->getOne($toClientId));
//        if($accountFrom === null) {
//            throw new \InvalidArgumentException('Account does not exists, id = '.$fromClientId);
//        }
//        if($accountTo === null) {
//            throw new \InvalidArgumentException('Account does not exists, id = '.$toClientId);
//        }
//        if($this->calculateBalance($fromClientId) >= $miles && $accountFrom->isActive()) {
//            $milesList = $this->milesRepository->findAllByClient($fromClient);
//
//            foreach ($milesList as $iter) {
//                if($iter->isSpecial() || $iter->getExpirationDate() > $this->clock->now()) {
//                    if($iter->getMiles() <= $miles) {
//                        $iter->setClient($accountTo->getClient());
//                        $miles -= $iter->getMiles();
//                    } else {
//                        $iter->setMiles($iter->getMiles() - $miles);
//                        $_miles = new AwardedMiles();
//
//                        $_miles->setClient($accountTo->getClient());
//                        $_miles->setSpecial($iter->isSpecial());
//                        $_miles->setExpirationDate($iter->getExpirationDate());
//                        $_miles->setMiles($iter->getMiles());
//
//                        $miles -= $iter->getMiles();
//
//                        $this->milesRepository->save($_miles);
//                    }
//                    $this->milesRepository->save($iter);
//                }
//            }
//
//            $accountFrom->increaseTransactions();
//            $accountTo->increaseTransactions();
//
//            $this->accountRepository->save($accountFrom);
//            $this->accountRepository->save($accountTo);
//        }
//    }
//
//    private function isSunday(): bool
//    {
//        return $this->clock->now()->format('l') === 'sunday';
//    }
//}
